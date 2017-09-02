#!/bin/bash

/home/$USER/.rvm/bin/rvm use $(echo $(ruby -e 'print RUBY_VERSION'))@${PWD##*/} do ruby main.rb $(zenity --info --text "Выберите папку с .docx оригиналами" && zenity --file-selection --directory)
