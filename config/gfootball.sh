PRE_BUILD_COMMANDS='sed -i "s/cmake ./cmake . -DBoost_NO_BOOST_CMAKE=ON/" gfootball/build_game_engine.sh'
MODULE_BUILD_DEPS="sdl2 opencv boost"
MODULE_RUNTIME_DEPS="opencv"
