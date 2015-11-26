
from distutils.core import setup
import py2exe

major    = 1
minor    = 0
revision = 1
        
version  = '%s.%s.%s' % (major, minor, revision)
    
prog = dict(
    description = 'mssql',
    script='mssql.py',
    )


options = {
    'includes' : [ 'decimal' ],         # dynamically loaded by pyodbc
    
    'excludes' : ['bz2',
                  'calendar',
                  'getopt',
                  'macpath',
                  'os2emxpath',
                  'popen2',
                  'posixpath',
                  'quopri',
                  '_ssl',
                  ],
    
    'dll_excludes' : ['w9xpopen.exe', 'msvcr71.dll' ],

    'ascii'    : '1',
    'optimize' : '1',
    }


setup(
    name        = 'mssql',
    description = 'An isql/osql replacement for emacs sql-mode',
    version     = version,
    zipfile     = None,
    options     = { 'py2exe' : options },
    console     = [ prog ],
    )
