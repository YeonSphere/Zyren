@echo off 
 
if "%%1"=="run" ( 
    if not "%%2"=="" ( 
        echo Running %%2 
        .\seoggi.exe src\interpreter.seo %%2 
    ) else ( 
        echo Please specify a file to run 
    ) 
) else if "%%1"=="build" ( 
    echo Building Seoggi project 
    .\seoggi.exe build\build.seo 
) else if "%%1"=="test" ( 
    echo Running tests 
    .\seoggi.exe tests\unit_tests.seo 
    .\seoggi.exe tests\integration_tests.seo 
) else if "%%1"=="compile" ( 
    if not "%%2"=="" ( 
        echo Compiling %%2 
        .\seoggi.exe src\compiler.seo %%2 
    ) else ( 
        echo Please specify a file to compile 
    ) 
) else if "%%1"=="debug" ( 
    if not "%%2"=="" ( 
        echo Debugging %%2 
        .\seoggi.exe src\interpreter.seo --debug %%2 
    ) else ( 
        echo Please specify a file to debug 
    ) 
) else ( 
    echo Unknown command: %%1 
    echo Available commands: run, build, test, compile, debug 
) 
