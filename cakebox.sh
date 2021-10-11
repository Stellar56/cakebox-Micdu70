#!/usr/bin/env bash

# _________         __         ___.
# \_   ___ \_____  |  | __ ____\_ |__   _______  ___
# /    \  \/\__  \ |  |/ // __ \| __ \ /  _ \  \/  /
# \     \____/ __ \|    <\  ___/| \_\ (  <_> >    <
#  \______  (____  /__|_ \\___  >___  /\____/__/\_ \
#         \/     \/     \/    \/    \/            \/
# Version: Light
# Author:
#       @Tuxity
#       @mpgn
#
# Fork version:
#       @Micdu70

function usage {
    echo "Usage: ./$0 [install-full | install-cakebox | install-prerequis | update]"
    exit 0
}

# --------------------------- [ INSTALLATION PREREQUIS ] ---------------------------

function install-prereq {
    echo "Installation des prérequis de Cakebox-light :"
    read -p "Appuyez sur une touche pour continuer ..."

    read -e -p "Quelle est votre distribution linux ? (debian = d | ubuntu = u)" DISTRIB

    cd /tmp

    if [ $DISTRIB == "d" ] ; then
        echo "Installation de la dernière version de PHP ..."
        echo "deb http://packages.dotdeb.org wheezy all
              deb-src http://packages.dotdeb.org wheezy all" >> /etc/apt/sources.list
        wget http://www.dotdeb.org/dotdeb.gpg
        apt-key add dotdeb.gpg
        rm dotdeb.gpg
        aptitude update && aptitude upgrade
        aptitude install php5 php5-curl curl git python g++ make
    else
        add-apt-repository ppa:ondrej/php5
        apt-get update
        apt-get install php5 php5-curl curl git build-essential
    fi

    echo "Installation/Mise à jour de Composer ..."
    if hash composer 2>/dev/null; then
        /usr/local/bin/composer self-update
    else
        curl -sS http://getcomposer.org/installer | php
        mv /tmp/composer.phar /usr/bin/composer
        chmod +x /usr/bin/composer
    fi

    echo "Installation de NodeJS ..."
    wget -N http://nodejs.org/dist/node-latest.tar.gz
    tar xzvf node-latest.tar.gz && cd node-v*
    ./configure
    make
    make install

    echo "Installation/Mise à jour de Bower ..."
    if hash bower 2>/dev/null; then
        bower update --allow-root
    else
        npm install -g bower
    fi
}


# --------------------------- [ INSTALLATION CAKEBOX ] ---------------------------


function install-cakebox {

    echo "Installation de Cakebox-light ..."
    read -p "Appuyez sur une touche pour continuer ..."
    cd $1 #répertoire d'installation cakebox passer en parametre

    git clone https://github.com/Micdu70/cakebox.git cakebox && cd cakebox
    LASTEST=$(git describe --abbrev=0)
    git checkout tags/$LASTEST
    composer install
    bower install --allow-root

    cp config/default.php.dist config/default.php

    # Update Root directory Cakebox have to scan
    sed -i 's%\$app\[\"cakebox.root\"\] = \"\/var\/www\/\"\;%\$app\[\"cakebox.root\"] = \"'$2'\"\;%'  config/default.php

    echo -e "----------------------- CAKEBOX-LIGHT ---------------------\n"
    echo -e "Cakebox-light est maintenant installé dans le répertoire "$1".\n"
    echo -e "Il vous faut maintenant configurer votre serveur pour pouvoir accéder à cakebox depuis le web.\n"
    echo -e "Pour cela, rendez-vous sur le wiki, rubrique : Comment configurer votre serveur web Apache 2, NGinx ou LigHttpd ?\n";
    echo -e "Bon stream !\n"
    read -p "Appuyez sur une touche pour terminer ..."

}

# --------------------------- [ UPDATE CAKEBOX ] ---------------------------

function update {
    echo "Mise à jour de Cakebox-light ..."
    read -p "Appuyez sur une touche pour continuer ..."
    echo ""
    read -e -p "Où se trouve votre répertoire d'installation de Cakebox ? (ex: /var/www/cakebox) " REP2

    if cd $REP2 2> /dev/null ; then

        git remote set-url origin https://github.com/Micdu70/cakebox.git
        git fetch --tags
        git checkout $(git describe --tags $(git rev-list --tags --max-count=1))
        composer self-update
        composer update
        bower update --allow-root
        echo ""
        echo "Mise à jour terminée."
        echo ""
    else
        echo ""
        echo "Erreur : Vérifiez le chemin vers votre répertoire cakebox."
        echo ""
    fi

}

# --------------------------- [ répertoire D'INSTALLATION + SCAN ] ---------------------------

function repertoire-install {

    read -e -p "Entrez le répertoire où s'installera Cakebox-light (ex /var/www/) : " CAKEREP
    if cd $CAKEREP 2> /dev/null ; then
        echo -e "L'installation se fera dans '$CAKEREP'.\n" 1>&2
    else
        mkdir $CAKEREP
        echo -e "Le répertoire '$CAKEREP' a été créé.\n" 1>&2
        echo -e "L'installation se fera dans celui-ci.\n" 1>&2
    fi
    echo $CAKEREP
}

function repertoire-scan {

    read -e -p "Entrez le répertoire à scanner : " REP
    if cd $REP 2> /dev/null ; then
        echo -e "Répertoire scanné par Cakebox-light : '$REP'.\n" 1>&2
    else
        mkdir $REP
        echo -e "Le répertoire '$REP' a été créé.\n" 1>&2
    fi
    echo $REP
}

# --------------------------- [ VERIFICATION DE L'UTILISATEUR ROOT ] ---------------------------

user=$(whoami)
if [ root != $user ] ; then
    echo "Privilèges insuffisants, vous devez être en root"
    echo "Lancez la commande : sudo ./cakebox.sh"
    exit 1
fi

# --------------------------- [ CHOIX UTILISATEUR ] ---------------------------

echo "_________         __         ___.                 "
echo "\_   ___ \_____  |  | __ ____\_ |__   _______  ___"
echo "/    \  \/\__  \ |  |/ // __ \| __ \ /  _ \  \/  /"
echo "\     \____/ __ \|    <\  ___/| \_\ (  <_> >    < "
echo " \______  (____  /__|_ \\___  >___  /\____/__/\_  \\"
echo "        \/     \/     \/    \/    \/            \/"
echo -e "\n"
echo -e "Début de l'installation de Cakebox-light....\n"

case $1 in
    install-prerequis)
        # --------------------------- [ INSTALLATION ONLY PREREQUIS] ---------------------------
        install-prereq
        ;;
    install-full)
        # --------------------------- [ INSTALLATION CAKEBOX-LIGHT + PREREQUIS] ---------------------------
        CAKEREP=$(repertoire-install)
        REP=$(repertoire-scan)
        install-prereq
        install-cakebox $CAKEREP $REP
        ;;
    install-cakebox)
        # --------------------------- [ INSTALLATION ONLY CAKEBOX-LIGHT] ---------------------------
        CAKEREP=$(repertoire-install)
        REP=$(repertoire-scan)
        install-cakebox $CAKEREP $REP
        ;;
    update)
        update
        ;;
    *)
        usage
esac
