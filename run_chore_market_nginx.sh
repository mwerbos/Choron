#!/bin/sh

# Script to run the chore market with nginx serving static assets.
# and with multiple production servers accessed via nginx.

echo "Starting nginx..."
sudo nginx -c "${PWD}/nginx/nginx.conf"

# Runs the ~/ chore market
echo "Starting unicorn server..."
unicorn_rails -c config/unicorn.rb -E tilde_slash -D
echo "Starting rake jobs:work..."
echo "Nevermind, rake jobs:work is disabled for devl reasons."
# rake jobs:work RAILS_ENV=tilde_slash &

# TODO get both to run at once
# Runs the castle hauser chore market
# unicorn_rails -c config/unicorn.rb -E castle_hauser -D
# rake jobs:work RAILS_ENV=castle_hauser &

# How to kill these processes:
## nginx:
# sudo nginx -s quit (graceful) or
# sudo nginx -s stop (brutal)
## unicorn:
# ps aux | grep unicorn
# then kill the process labeled "unicorn_rails master"
## job worker:
# (TODO) 
