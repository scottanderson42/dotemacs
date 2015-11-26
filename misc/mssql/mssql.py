
from __future__ import print_function

import sys, traceback, re
import pyodbc
from itertools import *

RE_SEMI  = re.compile(r'(.*) ; \s*$', re.VERBOSE)
RE_BLANK = re.compile(r'^ \s* $', re.VERBOSE)

cnxn     = None
cursor   = None
buffer   = []
commands = {}

pyodbc.pooling = False

# The connection parameters passed to the program, keyed by the ODBC keyword.  The DATABASE parameter is changed by the
# "use" command to the current database.
connect_params = {}

variables = { }

substitute = False # Use `variables`


OUTPUT_MODES = ['fixed', 'grid', 'tabs']

output_mode = 'fixed'


def current_db():
    return connect_params['DATABASE']


class CommandError(Exception): pass

def msg(fmt, *args):
    """
    Prints a message then flushes the buffer.
    """
    msg = str(fmt)
    if args:
        try:
            msg = fmt % args
        except:
            print('WARNING: Unable to format message properly')
            msg = fmt + ' '.join([ str(arg) for arg in args ])

    print(msg)
    sys.stdout.flush()


def main():

    if not connect():
        return 1

    # Lookup the commands we support.
    for attr, value in globals().items():
        if attr.startswith('cmd_'):
            commands[attr[4:]] = value

    while 1:
        try:
            input_loop()
        except SystemExit:
            return 0
        except:
            print(traceback.format_exc())
            sys.stdout.flush()

def input_loop():
    while 1:
        try:
            line = sys.stdin.readline()
            if not line:
                raise SystemExit()

            end = False
            m = RE_SEMI.match(line)
            if m:
                line = m.group(1)
                end = True

            if perform_variable_op(line):
                print
                sys.stdout.flush()
                continue

            if execute_command(line):
                print
                sys.stdout.flush()
                continue

            if not buffer and RE_BLANK.match(line):
                # If the buffer is empty, don't add blank lines.
                continue

            buffer.append(line)

            if end:
                for attempt in range(2):
                    try:
                        execute_sql(''.join(buffer))
                        break
                    except pyodbc.Error, ex:
                        if ex.args[0] != '08S01':
                            raise
                        msg('Disconnected: {}'.format(ex))
                        msg('Reconnecting and retrying')
                        connect()

                del buffer[:]

        except CommandError as ex:
            msg(ex)
            del buffer[:]

        except pyodbc.Error as ex:
            msg(ex)
            del buffer[:]


def _subvar(match):
    var = match.group(1) or match.group(2)
    if var not in variables:
        raise CommandError('Variable ${} is not set'.format(var))
    return variables[var]

re_variables = re.compile(r'(?<! \$ ) \$ (?: {(\w+)} | (\w+) )', re.VERBOSE)

def execute_sql(sql):

    sql = sql.strip()
    if not sql:
        return

    # Replace variables as necessary.
    if substitute:
        sql = re_variables.sub(_subvar, sql)
        sql = sql.replace('$$', '$')

    cursor.execute(sql)

    if cursor.description:
        print_results(cursor)
        return

    if cursor.rowcount == 1:
        msg('1 row')
    else:
        msg('%s rows', cursor.rowcount)

    cnxn.commit()


re_varname    = re.compile(r'^ (?:\.\s*)? \$(\w+)$', re.VERBOSE)
re_assignment = re.compile(r'^ (?:\.\s*)? \$(\w+) \s* = \s* (.+)?$', re.VERBOSE)

def perform_variable_op(line):
    """
    Determines if the line is a variable operation.  If so, the operation is performed and True is returned.
    If not, False is returned.
    """
    m = re_assignment.match(line)
    if m:
        assign(line, m)
        return True

    m = re_varname.match(line)
    if m:
        name = m.group(1)
        if name not in variables:
            print('Variable ${} is not set'.format(name))
        else:
            print('${} = {}'.format(name, variables[name]))
        return True

    return False


def assign(line, match):
    name  = match.group(1)
    value = match.group(2)
        
    value = value and value.strip()

    if not value:
        # If no value is provided, we delete the value.  (Quotes must be used to set an empty string)
        # $var =
        if name not in variables:
            print('Variable ${} is not set'.format(name))
        else:
            variables.pop(name)
            print('Unset ${}'.format(name))
        return

    variables[name] = value
    print('Set ${} to "{}"'.format(name, value))
    
def execute_command(line):
    """
    Determines if the line is a command.  If so, the command is executed and True is returned.  If not, False is
    returned, indicating the line is part of SQL input.
    """
    # See if the first token is a command we know.  Require it to be in the first column (no spaces) so we don't
    # pickup column names in word wrapped commands.  (We might have to supply regular expressions for each command.
    # This could make it more difficult to give nice error messages for invalid commands, however, because we
    # wouldn't pass the invalid line to the command function.)

    line = line.strip()
    if not line:
        return False

    if not line.startswith('\\'):
        return False

    line = line[1:] # remove backslash

    keyword = line.split(None, 1)[0].lower()

    try:
        func = commands[keyword]
        func(line)
        msg('')
        return True

    except KeyError:
        return False

    except CommandError, ex:
        msg(ex)
        return True


def cmd_vars(line):
    "\\vars: Toggle using variables"
    global substitute
    substitute = not substitute
    print('Substitute variables:', substitute)


def cmd_set(line):
    "\\set: set or print variables (only print is working right now)"

    if not variables:
        print('no variables')
        return

    maxlhs = max(len(v) for v in variables.keys()) + 1 # (+1 for leading $)
    maxrhs = max(len(v) for v in variables.values()) 

    fmt = '{{:>{}}} = {{:<{}}}'.format(maxlhs, maxrhs)
    
    for key, value in variables.items():
        print(fmt.format('$' + key, value))


def cmd_q(line):
    "\\q: quit"
    raise SystemExit()

def cmd_h(line):
    "\\h: print this help"
    
    cmds = [(name[4:], func) for (name, func) in globals().items() if name.startswith('cmd_')]
    
    results = []
    for name, func in cmds:
        results.append(func.__doc__ or ("\\%s" % name))

    msg('Commands:\n')
    msg('\n'.join(results))


# def cmd_cols(line):
#     "\\cols <table>: display column names"
# 
#     parts = line.split()
#     if len(parts) != 2:
#         raise CommandError('usage: cols <table>')
# 
#     cursor.columns(parts[1])
# 
#     for row in cursor:
#         print(row[3].lower())
#     print
#     sys.stdout.flush()


def cmd_example(line):
    parts = line.split()
    if len(parts) != 2:
        raise CommandError('.example <table>')

    cursor.execute("select top 1 * from %s" % parts[1])
    print_results(cursor)


def cmd_d(line):
    "\\d <object>: prints information about <object>"

    parts = line.split()
    if len(parts) != 2:
        raise CommandError('\\d <object>')

    obj = parts[1]

    # First figure out what it actually is.
    row = cursor.execute("select xtype from sysobjects o where name=?", obj).fetchone()
    if not row:
        # Indexes are not in sysobjects.  We'll make fake xtypes.
        row = cursor.execute("select 'IX' as xtype from sys.indexes where name=?", obj).fetchone()

    if not row:
        raise CommandError('Did not find %s in sysobjects' % obj)

    xtype = row.xtype.strip()

    map_type_to_name = {
        'C':  'Check constraint',
        'D':  'Default constraint',
        'F':  'Foreign Key constraint',
        'L':  'Log',
        'P':  'Stored procedure',
        'PK': 'Primary Key constraint',
        'RF': 'Replication Filter stored procedure',
        'S':  'System table',
        'TR': 'Trigger',
        'U':  'User table',
        'UQ': 'Unique constraint',
        'V':  'View',
        'X':  'Extended stored procedure',

        # Made up xtypes!
        'IX': 'Index',
        }

    typename = map_type_to_name.get(xtype, 'unknown xtype "%r"' % xtype)

    funcname = '_details_xtype_%s' % xtype
    func = globals().get(funcname)
    if func:
        func(obj)
    else:
        print('%s: %s' % (obj, typename))

def _details_xtype_U(obj):
    rows = cursor.execute(
        """
        select lower(column_name) as column_name,
               is_nullable,
               data_type,
               character_maximum_length,
               numeric_precision,
               numeric_scale
          from information_schema.columns
         where table_name = ?
         order by ordinal_position
        """, obj).fetchall()
    
    results = []
    for row in rows:
        if row.character_maximum_length:
            typedesc = '%s(%s)' % (row.data_type, row.character_maximum_length)
        elif row.numeric_precision and row.data_type not in ('int', 'float'):
            typedesc = '%s(%s,%s)' % (row.data_type, row.numeric_precision, row.numeric_scale)
        else:
            typedesc = row.data_type

        if row.is_nullable == 'NO':
            typedesc += ' not null'

        results.append((row.column_name, typedesc))

    maxlhs = max(len(t[0]) for t in results)
    maxrhs = max(len(t[1]) for t in results)

    fmt = '{{:<{}}} {{:<{}}}'.format(maxlhs, maxrhs)

    print('Table')
    print()
    print(obj)
    print(('-' * maxlhs) + ' ' + ('-' * maxrhs))
    for t in results:
        print(fmt.format(t[0], t[1]))


def _details_xtype_IX(obj):
    rows = cursor.execute(
        """
        select o.name  as table_name, 
               co.name as column_name,
               i.is_unique
          from sys.indexes i 
          join sys.objects o
               on i.object_id = o.object_id
          join sys.index_columns ic
               on  ic.object_id = i.object_id 
               and ic.index_id = i.index_id
          join sys.columns co
               on  co.object_id = i.object_id 
               and co.column_id = ic.column_id
        where i.name = ?
        order by ic.key_ordinal
        """, obj).fetchall()

    maxwidth = max(len(rows[0].table_name), max(len(row.column_name) for row in rows))

    print('%s Index' % ((rows[0].is_unique) and 'Unique' or 'Non-unique'))
    print()
    print(rows[0].table_name)
    print('-' * maxwidth)
    for row in rows:
        print(row.column_name)
    

def _details_xtype_PK(obj):
    rows = cursor.execute(
        """
        select kcu.table_name, kcu.column_name
          from information_schema.table_constraints as c
          join information_schema.key_column_usage as kcu
            on kcu.constraint_schema = c.constraint_schema
           and kcu.constraint_name = c.constraint_name
           and kcu.table_schema = c.table_schema
           and kcu.table_name = c.table_name
         where c.constraint_name = ?
         order by kcu.ordinal_position
        """, obj).fetchall()

    maxwidth = max(len(rows[0].table_name), max(len(row.column_name) for row in rows))

    print('Primary Key')
    print()
    print(rows[0].table_name)
    print('-' * maxwidth)
    for row in rows:
        print(row.column_name)


def _details_xtype_F(obj):
    rows = cursor.execute(
        """
        select lower(c.table_name) as from_table,
               lower(kcu.column_name) as from_column,
               lower(c2.table_name) as to_table,
               lower(kcu2.column_name) as to_column
          from information_schema.table_constraints c 
          join information_schema.key_column_usage kcu 
                   on  c.constraint_schema = kcu.constraint_schema 
                   and c.constraint_name = kcu.constraint_name 
          join information_schema.referential_constraints rc 
                   on  c.constraint_schema = rc.constraint_schema 
                   and c.constraint_name = rc.constraint_name 
          join information_schema.table_constraints c2 
                   on  rc.unique_constraint_schema = c2.constraint_schema 
                   and rc.unique_constraint_name = c2.constraint_name 
          join information_schema.key_column_usage kcu2 
                   on  c2.constraint_schema = kcu2.constraint_schema 
                   and c2.constraint_name = kcu2.constraint_name 
                   and kcu.ordinal_position = kcu2.ordinal_position 
         where c.constraint_name = ?
         order by kcu.ordinal_position
        """, obj).fetchall()

    maxlhs = max(len(rows[0].from_table), max(len(row.from_column) for row in rows))
    maxrhs = max(len(rows[0].to_table),   max(len(row.to_column)   for row in rows))

    fmt = '{{:>{}}} --> {{:<{}}}'.format(maxlhs, maxrhs)

    print('Foreign Key')
    print()
    print(fmt.format(rows[0].from_table, rows[0].to_table))
    print('-' * (maxlhs + maxrhs + 5))
    for row in rows:
        print(fmt.format(row.from_column, row.to_column))


def cmd_cols(line):
    parts = line.split()
    if not (2 <= len(parts) <= 3):
        raise CommandError('.cols <table> [<column>]')

    if len(parts) == 2:
        cursor.columns(parts[1])
    else:
        column = parts[2].replace('*', '%').replace('.', '_')
        cursor.columns(parts[1], column=column)

    print_results(cursor)


def cmd_pkey(line):
    "\\pkey <table>: display the primary key"

    parts = line.split()
    if len(parts) != 2:
        raise CommandError('.pkey <table>')

    cursor.primaryKeys(parts[1])
    print
    for row in cursor:
        print(row[3])


def cmd_fkeys(line):
    "\\fkeys <table> [reverse]: lists foreign keys; reverse returns keys using this table"

    parts = line.split()
    if len(parts) != 2 and (len(parts) != 3 and parts[-1] == 'reverse'):
        raise CommandError('.fkeys <table>')

    reverse = bool(len(parts) == 3 and parts[-1] == 'reverse')

    # Unfortunately we can't pass None for keyword parameters.  Need an update to pyodbc.
    if not reverse:
        cursor.foreignKeys(foreignTable=parts[1])
    else:
        cursor.foreignKeys(table=parts[1])

    # Each entry is a tuple (<othertable>, { thiscol : othercol })
    map_name_to_info = {}

    for row in cursor:
        info = map_name_to_info.get(row.fk_name)
        if not info:
            info = (row.pktable_name, {})
            map_name_to_info[row.fk_name] = info
        map = info[1]

        fk = row.fktable_name + '.' + row.fkcolumn_name
        pk = row.pktable_name + '.' + row.pkcolumn_name
        map[fk] = pk

    for fkey in sorted(map_name_to_info):
        othertable, cols = map_name_to_info[fkey]
        print('%s' % fkey)
        maxwidth = max(len(thiscol) for thiscol in cols.keys())
        for thiscol in sorted(cols.keys()):
            othercol = cols[thiscol]
            print('  %-*s --> %s' % (maxwidth, thiscol, othercol))
        print


def cmd_dt(line):
    "\\dt [pattern]: list tables matching the pattern"

    parts = line.split()
    if len(parts) < 1 or len(parts) > 2:
        raise CommandError('usage: \\dt [pattern]')

    sql = ("""
           select table_name
             from information_schema.tables
            --{where} where table_name like ?
            order by table_name
           """)

    params = []
    if len(parts) != 1:
        sql = sql.replace('--{where}', '')
        params.append(parts[1].replace('*', '%').replace('.', '_'))

    cursor.execute(sql, *params)
    print_results(cursor)
    

def cmd_r(line):
    "\\r: Reset (clear) the query buffer and reconnect"
    del buffer[:]
    msg('Input cleared')

    global cnxn, cursor
    cursor.close()
    cnxn.close()

    msg('Closed')
    connect()
    cursor.execute('select 1')


def cmd_db(line):
    msg('Database: %s', connect_params['DATABASE'])


def cmd_l(line):
    "\\l: List all databases"
    cursor.execute("select name from sys.databases order by name")
    print_results(cursor)

def cmd_c(line):
    "\\c <database>: connect to another database on the same server"
    global cnxn, cursor

    db = line.split()[1:]
    if len(db) != 1:
        raise CommandError('usage: use <database>')
    db = db[0]

    connect_params['DATABASE'] = db

    cnxn = _new_connection()
    cursor = cnxn.cursor()

    msg('Connected to %s' % db)


def cmd_output(line):
    "\\output [{}]".format('|'.join(OUTPUT_MODES))

    global output_mode

    if line.strip() == 'output':
        print('Current output mode: {}'.format(output_mode))
        return

    modes = '|'.join(OUTPUT_MODES)
    m = re.match(r'output\s+({})?\s*'.format(modes), line)
    if not m:
        raise CommandError('Valid output modes: {}'.format(modes))

    output_mode = m.group(1)
    print('Output mode set to {}'.format(output_mode))


def convert(row):
    for i, val in enumerate(row):
        if (type(val) is bytearray):
            row[i] = '<binary %d bytes>' % len(row[i])
        elif val is None:
            row[i] = 'NULL'
        elif not isinstance(val, basestring):
            row[i] = str(val)
    return row


def print_results(cursor):
    """
    Displays query results.
    """
    try:
        printfunc = globals()['_print_results_{}'.format(output_mode)]
        printfunc(cursor)
    except:
        traceback.print_exc()
        sys.stderr.flush()

    print()
    sys.stdout.flush()


def _print_results_grid(cursor):
    batch = []

    cols = [ (t[0] or '(none)') for t in cursor.description ]
    rows = [ convert(row) for row in cursor ]

    lens   = (tuple(len(c) for c in row) for row in rows)
    hdrlens = (len(c) for c in cols)

    widths = imap(max, izip(*lens)) # is "*lens" efficient?
    widths = [ max(h,c) for h,c in zip(hdrlens, widths) ]

    sep    = '+'.join('-' * w for w in widths)
    sep    = '+' + sep + '+'
    hdrsep = sep.replace('-', '=')

    fmt = u'|'.join('{{:{}}}'.format(w) for w in widths)
    fmt = u'|' + fmt + '|'

    batch.append(sep)
    batch.append(fmt.format(*cols))
    batch.append(hdrsep)

    for row in rows:
        batch.append(fmt.format(*row))
        batch.append(sep)

        if len(batch) >= 1000:
            print('\n'.join(batch))
            batch = []

    if batch:
        print('\n'.join(batch))


def _print_results_fixed(cursor):
    batch = []

    cols = [ (t[0] or '(none)') for t in cursor.description ]
    rows = [ convert(row) for row in cursor ]

    hdrlens = (len(c) for c in cols)

    if rows:
        lens = (tuple(len(repr(c))-2 for c in row) for row in rows)
        widths = imap(max, izip(*lens)) # is "*lens" efficient?
        widths = [ max(h,c) for h,c in zip(hdrlens, widths) ]
    else:
        widths = list(hdrlens)

    sep = u' '.join('-' * w for w in widths)
    fmt = u' '.join('{{:{}}}'.format(w) for w in widths)

    batch.append('')
    batch.append(fmt.format(*cols))
    batch.append(sep)

    for row in rows:
        # row = [ repr(v)[1:-1] for v in row ]

        batch.append(fmt.format(*row))

        if len(batch) >= 1000:
            _print_ascii(batch)
            batch = []

    if batch:
        _print_ascii(batch)


def _print_ascii(batch):
    # At the moment, emacs seems to require ASCII our else our output stream is set to ASCII.  I don't really care
    # about seeing non-ascii right now, so I'll convert.
    s = '\n'.join(batch)
    s = s.encode('ascii', 'ignore')
    print(s)


def _print_results_tabs(cursor):
    batch = []

    cols = [ (t[0] or '(none)') for t in cursor.description ]
    rows = [ convert(row) for row in cursor ]

    batch.append('')
    batch.append('\t'.join(cols))
    batch.append('')

    for row in rows:
        batch.append('\t'.join(row))

        if len(batch) >= 1000:
            print('\n'.join(batch))
            batch = []

    if batch:
        print('\n'.join(batch))


def connect():
    global cnxn, cursor

    MAP_ARGS = { '-S' : 'SERVER',
                 '-d' : 'DATABASE',
                 '-U' : 'UID',
                 '-P' : 'PWD' }
        
    args = sys.argv[1:]

    # If no user-id or password is configured, emacs will pass "-E".
    if '-E' in args:
        args.remove('-E')
        connect_params['Trusted_Connection'] = 'yes'

    while args:
        keyword = MAP_ARGS.get(args[0], None)
        if not keyword:
            raise SystemExit('Unknown parameter: "%s"  commandline="%s"' % (args[0], ' '.join(sys.argv)))
        if len(args) == 1:
            raise SystemExit('Missing value for parameter "%s"  commandline="%s"' % (args[0], ' '.join(sys.argv)))
        connect_params[keyword] = args[1]
        args.pop(0)
        args.pop(0)

    if 'SERVER' not in connect_params:
        connect_params['SERVER'] = 'localhost'

    try: cursor = None
    except: pass
    
    try: cnxn = None
    except: pass


    for driver in ['SQL Server Native Client 11.0', 'SQL Server Native Client 10.0', 'SQL Server']:
        connect_params['DRIVER'] = driver

        try:
            cnxn   = _new_connection()
        except pyodbc.Error, ex:
            if ex.args[0] == 'IM002':
                continue
            msg(ex)
            return False

        cursor = cnxn.cursor()

        msg('Connected to {SERVER} / {DATABASE}'.format(**connect_params))
        return True

    return False


def _new_connection():
    s = ';'.join([ '%s=%s' % (key, value) for key, value in connect_params.items() ])
    return pyodbc.connect(s)

    
if __name__ == '__main__':
    main()
