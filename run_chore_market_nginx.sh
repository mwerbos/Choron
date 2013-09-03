#!/bin/sh

# Script to run the chore market with nginx serving static assets.
# and with multiple production servers accessed via nginx.

echo "Starting nginx..."
sudo nginx -c "${PWD}/nginx/nginx.conf"

## Runs the ~/ chore market
echo "For the ~/ chore market:"

# Precompile assets: Only necessary if CSS/layouts have changed recently.
#echo "Precompiling assets..."
#RAILS_ENV=tilde_slash bundle exec rake assets:precompile 

echo "Starting unicorn server..."
RAILS_RELATIVE_URL_ROOT='/tilde_slash' unicorn_rails -c config/unicorn_tilde_slash.rb -E tilde_slash -D

echo "Starting rake jobs:work..."
echo "Nevermind, rake jobs:work is disabled for devl reasons."
# rake jobs:work RAILS_ENV=tilde_slash &

## Runs the hauser chore market
echo "For the Castle Hauser chore market:"

# Precompile assets: Only necessary if CSS/layouts have changed recently.
#echo "Precompiling assets..."
#RAILS_ENV=castle_hauser bundle exec rake assets:precompile 

echo "Starting unicorn server..."
RAILS_RELATIVE_URL_ROOT='/castle_hauser' unicorn_rails -c config/unicorn_castle_hauser.rb -E castle_hauser -D

echo "Starting rake jobs:work..."
echo "Nevermind, rake jobs:work is disabled for devl reasons."
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
