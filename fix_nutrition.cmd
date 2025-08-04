@echo off
echo Creating backup of current Nutrition.dart file...
copy "lib\Features\codia\Nutrition.dart" "lib\Features\codia\Nutrition.dart.broken"
echo Copying fixed file...
copy "lib\Features\codia\Nutrition.dart.new" "lib\Features\codia\Nutrition.dart"
echo Done!
echo The original file is backed up as Nutrition.dart.broken 