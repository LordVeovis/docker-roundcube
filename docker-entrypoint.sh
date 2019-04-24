#!/bin/sh

ROOT_OVERLAY=/root_overlay
ROOT_WWW=/var/www/html
PHP_CONFIG=/usr/local/etc/php-fpm.d/www.conf

if [ -d "$ROOT_OVERLAY" ]; then
    echo "Merging overlay with stock roundcube"

    cd "$ROOT_OVERLAY"
    find . \( -type f -o -type l \) -print | \
        while read i;
        do
            d=`dirname "$i"`
            [ -d "$ROOT_WWW/$d" ] || mkdir -p "$ROOT_WWW/$d"
            cp "$i" "$ROOT_WWW/$i"
        done
fi

# https://gist.github.com/smileart/4597fa6a8afdf659d1d6
# param_1: string | param_2: file
is_option_in_file () {
  if [ ! -z "$1" ] && [ ! -z "$2" ]; then
    escape=$( echo $1 | sed -e 's/\[/\\[/g' -e 's/\]/\\]/g' )
    egrep -q "$escape" "$2"

    if [ $? = 0 ]
    then
      echo '1'
    else
      echo '0'
    fi
  fi
}

# param_1: string | param_2: file
get_option_line_number () {
  if [ ! -z "$1" ] && [ ! -z "$2" ]; then
   echo $(egrep -n "$1" "$2" | cut -f1 -d:)
  fi
}

# param_1: option | param_2: value | param_3: file
ini_set_option () {
  local ini_file="$3";
  local ini_option="^$1.*$";
  local original_option="$1"
  local new_option_value="$2"

  if [ $( is_option_in_file "$ini_option" "$ini_file" ) = "1" ]; then
    echo "Changed $1 value to $2 in the lines: " $(get_option_line_number "$ini_option" "$ini_file")
    sed -i -e "s/$ini_option/$original_option = $new_option_value/g" $ini_file
  else
    echo "$original_option = $new_option_value " >> $ini_file
  fi
}

if [ ! -z "$MAX_UPLOAD_SIZE" ]; then
    ini_set_option php_admin_value[upload_max_filesize] $MAX_UPLOAD_SIZE $PHP_CONFIG
    ini_set_option php_admin_value[post_max_size] $MAX_UPLOAD_SIZE $PHP_CONFIG
fi

exec docker-php-entrypoint $@