# Fonction qui permet d'ecrire le text passé en paramètre dans le fichier passé en paramètre
# @param text le texte à ecrire
# @param file le fichier (ou path/fichier) dans lequel ecrire
function ecriture(text::String, file::String)
    run(pipeline(`echo -e $text`, stdout=file))
end
