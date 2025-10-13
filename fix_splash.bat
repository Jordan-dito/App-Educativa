@echo off
echo Copiando tu imagen del birrete sobre los archivos splash...

copy /Y assets\images\birrete.png android\app\src\main\res\drawable\splash.png
copy /Y assets\images\birrete.png android\app\src\main\res\drawable-mdpi\splash.png
copy /Y assets\images\birrete.png android\app\src\main\res\drawable-hdpi\splash.png
copy /Y assets\images\birrete.png android\app\src\main\res\drawable-xhdpi\splash.png
copy /Y assets\images\birrete.png android\app\src\main\res\drawable-xxhdpi\splash.png
copy /Y assets\images\birrete.png android\app\src\main\res\drawable-xxxhdpi\splash.png

copy /Y assets\images\birrete.png android\app\src\main\res\drawable\background.png
copy /Y assets\images\birrete.png android\app\src\main\res\drawable-mdpi\background.png
copy /Y assets\images\birrete.png android\app\src\main\res\drawable-hdpi\background.png
copy /Y assets\images\birrete.png android\app\src\main\res\drawable-xhdpi\background.png
copy /Y assets\images\birrete.png android\app\src\main\res\drawable-xxhdpi\background.png
copy /Y assets\images\birrete.png android\app\src\main\res\drawable-xxxhdpi\background.png

echo ¡Listo! Tu imagen del birrete se ha copiado sobre todos los archivos splash.
pause
