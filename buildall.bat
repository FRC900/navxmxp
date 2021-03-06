REM Build all binaries

REM
REM Begin a command-line "clean build" of the navx protocol java library
REM

pushd .\java\navx
call ant clean build
popd

REM
REM Copy navx protocol java library file to project folders that need it.
REM

mkdir .\processing\libraries\navx\library\
copy .\java\navx\bin\*.jar .\processing\libraries\navx\library\ /Y

REM
REM Regrettably, adding a non-WPI java library to a WPI Library Java Project
REM is precluded, since the WPI build.xml uses ANT immutable variables
REM for the classpath.  Therefore, the navx protocol library sources must be copied
REM into the Java sample projects.
REM 

cp -r ./java/navx/src/* ./roborio/java/navXMXPSimpleRobotExample/src/

REM
REM Copy the navX protocol library .h files to the 
REM projects that need them.
REM

cp ./stm32/navx-mxp/IMU*.h ./arduino/navXTestJig/
cp ./stm32/navx-mxp/AHRS*.h ./arduino/navXTestJig/
cp ./stm32/navx-mxp/IMU*.h ./roborio/c++/navXMXP_CPlusPlus_RobotExample/src/
cp ./stm32/navx-mxp/AHRS*.h ./roborio/c++/navXMXP_CPlusPlus_RobotExample/src/


REM
REM Begin a command-line "clean build" of the Debug version of the navx-mxp firmware
REM

REM Use the GIT checkin count as the firmware revision number 

pushd .\stm32\navx-mxp
echo|set /p=#define NAVX_MXP_REVISION  > revision.h
git rev-list --count --first-parent HEAD >> revision.h
popd

rm -r -f ./build_workspace
mkdir build_workspace

C:\Eclipse\eclipsec.exe -nosplash -application org.eclipse.cdt.managedbuilder.core.headlessbuild -data ./build_workspace -import ./stm32 -cleanBuild navx-mxp/Debug
rmdir /S /Q stm32\bin
mkdir stm32\bin

@echo off
for /f %%i in ('grep NAVX_MXP_FIRMWARE_VERSION_MAJOR stm32/navx-mxp/version.h ^| sed 's/#define NAVX_MXP_FIRMWARE_VERSION_MAJOR/ /' ^| sed 's/^[ \t]*//'') do set VER_MAJOR=%%i
for /f %%i in ('grep NAVX_MXP_FIRMWARE_VERSION_MINOR stm32/navx-mxp/version.h ^| sed 's/#define NAVX_MXP_FIRMWARE_VERSION_MINOR/ /' ^| sed 's/^[ \t]*//'') do set VER_MINOR=%%i
for /f %%i in ('git rev-list --count --first-parent HEAD') do set VER_REVISION=%%i
set REVISION_STRING=%VER_MAJOR%.%VER_MINOR%.%VER_REVISION%
@echo on

copy .\stm32\Debug\navx-mxp.hex .\stm32\bin\navx-mxp_%REVISION_STRING%.hex

REM Build CSharp Components

call buildcsharp.bat

REM Build Processing components

call buildprocessing.bat

REM Build setup program

call buildsetup.bat

