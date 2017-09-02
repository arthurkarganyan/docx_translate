rvm use $(echo $(ruby -e 'print RUBY_VERSION'))@${PWD##*/} do ruby main.rb $(zenity --file-selection --directory)
