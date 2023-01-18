#!/bin/sh

export $(grep -v '^#' /srv/src/app/.env.install | xargs)

install_path=/srv/src/symfony_install
target_path=${WORKDIR}

On_Green='\033[42m'
NC='\033[0m' # No Color

rm -rf -r $install_path
if test -f "symfony.lock"; then
    echo -e "${On_Green}   Symfony already installed   ${NC}"
  else
    echo -e "${On_Green}   Installing Symfony start    ${NC}"
    curl -sS https://get.symfony.com/cli/installer | bash
    mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

    symfony new $install_path --version="6.3.*@dev" --webapp >/dev/null

    rm -rf $install_path/.git
    rm -rf $install_path/docker*

    echo -e "${On_Green}   Generate .env.local file   ${NC}"

    echo -e "# Copy from project env file" >> $install_path/.env.local
    cat ${WORKDIR}/.env.install >> $install_path/.env.local
    echo -e " " >> $install_path/.env.local
    echo -e " " >> $install_path/.env.local

    echo -e "# Generated by install" >> $install_path/.env.local
    cat docker/configs/php/.env.default >> $install_path/.env.local


    echo -e "DATABASE_URL=\"mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}?serverVersion=8&charset=utf8mb4\"" >> $install_path/.env.local


    echo -e "${On_Green}   Generate .gitignore file   ${NC}"

    cat ${WORKDIR}/.gitignore >> $install_path/.gitignore


    echo -e "${On_Green}   Copy files to project folder   ${NC}"
    echo -e "${On_Green}   This may take a few minutes   ${NC}"
    echo -e "${On_Green}   Wait for completion   ${NC}"

    rsync -avh  --remove-source-files --progress $install_path/ $target_path

    echo -e "${On_Green}  Delete tmp dir   ${NC}"
    rm -rf $install_path

    git add $target_path/.

    echo -e "${On_Green}   Install complete successful   ${NC}"
#    echo -e "${On_Green}   Run 'docker-compose up' now  ${NC}"
fi

    tail -f /dev/null
