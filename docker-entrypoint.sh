#!/bin/sh

ROOT_OVERLAY=/root_overlay
ROOT_WWW=/var/www/html
PHP_CONFIG=/usr/local/etc/php-fpm.d/www.conf
COMPOSER_FILE="$ROOT_WWW"/composer.json

if [ -n "$ROUNDCUBE_MODULES" ]; then
  #jq '.require |= . + { "toto": "talprout" }' composer.json

  tmpf1=`mktemp`
  tmpf2=`mktemp`
  cp "$COMPOSER_FILE" "$tmpf1"
  for m in $ROUNDCUBE_MODULES; do
    name=`echo $m | cut -d':' -f 1`
    version=`echo $m | cut -d':' -f 2`

    echo 'Installing module ' $name
    jq '.require |= . + { "'$name'": "'$version'" }' "$tmpf1" > "$tmpf2"
    mv "$tmpf2" "$tmpf1"

    composer update $name
  done

  mv "$tmpf1" "$COMPOSER_FILE"
  #composer install
fi

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

ini_set_option php_admin_value[file_uploads] On "$PHP_CONFIG"
ini_set_option php_admin_value[session.auto_start] Off "$PHP_CONFIG"
ini_set_option php_admin_value[mbstring.func_overload] 0 "$PHP_CONFIG"
ini_set_option php_admin_value[pcre.backtrack_limit] 100000 "$PHP_CONFIG"

if [ ! -z "$MAX_UPLOAD_SIZE" ]; then
    ini_set_option php_admin_value[upload_max_filesize] $MAX_UPLOAD_SIZE "$PHP_CONFIG"
    ini_set_option php_admin_value[post_max_size] $MAX_UPLOAD_SIZE "$PHP_CONFIG"
fi

exec docker-php-entrypoint $@