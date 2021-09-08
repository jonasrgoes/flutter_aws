prepare:
	flutter channel beta
	flutter upgrade --force
	flutter config --enable-web --enable-macos-desktop
	flutter doctor
	flutter devices

desktop:
	flutter config --enable-macos-desktop

# add support to macos platform on a existing project
macos: 
	flutter create --platforms=macos .

create:
	flutter create --platforms=macos app_name

upgrade:
	dart pub upgrade --major-versions

clean:
	flutter clean

run: clean
	flutter run -d macos

build:
	flutter build macos

ios-emulator:
	open -a Simulator.app &

android-emulator:
	emulator -avd Pixel_3_XL_API_28 -wipe-data &

# dotenv package to store sensitive data
# web platform is not compatible - dart:io
dotenv:
	dart pub global activate dotenv
	dart pub global run dotenv:new

# creates an environment using .env file
env:
	dart pub global run dotenv
