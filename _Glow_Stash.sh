#!/bin/sh
# -*- ENCODING: UTF-8 -*-

#ESTILOS DE LETRAS
tipo_bold_fuente_green="\e[1;32m"
tipo_bold_fuente_yellow="\e[1;33m"
tipo_bold_fuente_cyan="\e[1;36m"
tipo_bold_fuente_white="\e[1;37m"

#ESTILOS PARA MARCOS
tipo_bold_fuente_cyan_fondo_blue="\e[1;36;44m"
tipo_bold_fuente_cyan_fondo_green="\e[1;36;42m"
tipo_bold_fuente_green_fondo_cyan="\e[1;32;46m"
tipo_bold_fuente_green_fondo_blue="\e[1;32;44m"

#VALORES PREDETERMINADOS
color_texto_error="\e[1;31m"

glow_stash_all(){
    $(dialog --title "GLOW STASH" \
         --stdout \
         --msgbox "\nScript para subir archivos (*.md) a la nube de glow\
                  \n\nEl nombre de los archivos no debe contener espacios en blanco...
                  \n\nSe requiere la instalación de 'exa' (sustituto del comando 'ls')...
                  \n\nSe recomienda configurar un archivo .gitignore en la ruta principal...
                  \n\n¿Desea continuar?" 19 45)
    returncode=$?
    if [[ $returncode = 0 ]]; then
        clear
        stash_array_folders $(pwd)
    fi
	echo -e "\n${tipo_bold_fuente_yellow} Terminado! \e[0m\n"
}

stash_array_folders(){
    local path=${1}
	local only_dirs=($(exa ${path} --reverse --only-dirs --git-ignore))

	stash_array_files "${path}"
	for folder in ${only_dirs[@]}
    	do
        stash_array_folders "${path}/${folder}"
	done
}

stash_array_files(){
    local path=${1}
	local dirs_and_files=($(exa ${path} --reverse --git-ignore))
	local only_dirs=($(exa ${path} --reverse --only-dirs --git-ignore))
	local only_files=$(restar_arrays $(ArrayToStr ${dirs_and_files[@]}) $(ArrayToStr ${only_dirs[@]}))

    echo -e "\n${tipo_bold_fuente_green_fondo_blue}   Ruta  ==>   ${path}\e[0m"
    for file in ${only_files[@]}
        do
        stash_file "${path}" "${file}"
    done
}

stash_file(){
	local path=${1}
	local file=${2}
	local name_dir=${path##*/}
    echo -e "${tipo_bold_fuente_yellow}   $(glow stash -m "${name_dir} - ${file}" ${path}/${file})   ==>   ${name_dir} - ${file} \e[0m"
}

################################################
ArrayToStr(){
	local my_array_to_string=${@}
   	echo ${my_array_to_string// /---}
}

StrToArray(){
	local my_string_to_array=${@}
   	echo ${my_string_to_array//---/ }
}
# Solo acepta array en formato string separado por '---' como se indica en estas funciones
restar_arrays(){
   	declare -a todo=($(StrToArray ${1}))
   	declare -a directorios=($(StrToArray ${2}))
	for item in ${todo[@]}
 	do
		for temp in ${directorios[@]}
 		do
		    if [[ ${item} = ${temp} ]]
		    then
		    	todo=(${todo[@]/${item}/})
		    fi
	    done
	done
	echo ${todo[@]}
}
################################################

glow_stash_all
