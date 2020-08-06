#!/bin/bash

## Cria backups semanais de diretorios selecionados

## variables
LOG_LOC="/var/log/mybackup.log"
##

## Essa funcao vai checar pelos diretorios que queremos fazer backup
function check_dir_loc {
	if  [ ! -s "/backup_dirs.conf" ]
	then
		echo "Por favor, crie uma lista de diretorios para fazer o backup criando um arquivo backup_dir.conf no diretorio root"
		exit 1
	fi
}

## Essa funcao vai procurar pela localizacao de onde armazenar o backup
function check_backup_loc {
	if [ ! -s "/backup_loc.conf" ]
	then
		echo "Por favor, especifique o path completo para onde o backup sera enviado, criando um arquivo backup_loc.conf no diretorio root"
		exit 1
	fi
}

## Essa funcao vai checar se existe um schedule configurado pro backup
function check_schedule {
	if [ ! -s "/etc/cron.weekly/make_backup" ]
	then 
		# Copia o script para o diretorio cron.weekly
		sudo cp make_back.sh /etc/cron.weekly/make_backup
		echo "O schedule de backup foi configurado para rodar semanalmente"
		echo "A hora exata da execucao esta no arquivo /etc/crontab"

	fi 
}

## Essa funcao vai agregar, compactar e enviar o backup para o destino
function perform_backup {
	backup_path=$(cat /backup_loc.conf)
	
	echo "Iniciando backup..." > $LOG_LOC
	
	while read dir_path
	do	
		# Acha o nome do diretorio
		dir_name=$(basename $dir_path)
		
		# Cria o filename para o backup
		filename=$backup_path$dir_name.tar.gz

		# Agrega os diretorios e comprime o arquivo
		tar -zcf $filename $dir_path 2>> $LOG_LOC

		# Muda o permissionamento do backup
		chown artur:artur $filename

		echo "O backup de $dir_name esta completo" >> $LOG_LOC
	done < /backup_dirs.conf

	echo "Backup completo disponivel em:" >> $LOG_LOC
	date >> $LOG_LOC
}

check_dir_loc
check_backup_loc
check_schedule
perform_backup
