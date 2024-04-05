@echo off

@rem wsl内でビルドして成果物をwsl内に置くことで、windowsでビルドするより3倍以上高速化する。
@rem ビルド結果をwindowsバッチファイルから

@rem do at project directory
setlocal
set port=com5
set fqbn=m5stack:esp32:m5stack_core2
rem ここに、成果物のプロジェクト名でフォルダが作られる
set input_dir=\\wsl.localhost\Debian\home\XXXXX\Arduino\build\

@rem バッチファイルの親ディレクトリの名前を取得する
set parent=%~p0
rem echo %parent%
set parent=%parent:~1,-1%
rem echo %parent%
set parents="%parent:\=" "%"
rem echo %parents%
call :get_parent_name %parents%
rem echo "%parent_name%"

@rem build
set input_dir="%input_dir%%parent_name%"
echo arduino-cli upload --fqbn %fqbn% --input-dir %input_dir% --port %port%
rem arduino-cli upload --fqbn %fqbn% --input-dir %input_dir% --port %port%

pause
goto :eof

:get_parent_name
for %%i in (%*) do (set parent_name=%%~i)

:eof
