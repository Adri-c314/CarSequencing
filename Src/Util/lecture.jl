# Fonction qui permet de lire un fichier csv
# @param path l'adresse du fichier à etudier
# @return la matrice associer au fichier
function lectureCSV(path::String)
    # Ouverture du flux
    f=open(path)

    # recuperation de la premiere ligne pour connaitre la taille de la matrice
    ligneCourante = split(readline(f) , ";")

    # taille de la matrice carré
    taille = length(ligneCourante)

    # Creation de la matrice de string from le csv
    mat = zero(rand(taille,taille))

    # Ajout de la premiere ligne :
    for i = 1:taille
        # ajout de la valeur courante
        tmpLigne = ligneCourante[i]
        tmp = tryparse(Float64, tmpLigne)
        if typeof(tmp) == Nothing
            mat[1,i] = valeurForCaractere(String(tmpLigne), mat, 1, i)
        else
            mat[1,i] = tmp
        end

    end

    # Boucle sur toutes les lignes du fichier
    for j = 2:taille
        ligneCourante = split(readline(f) , ";")
        for i = 1:taille
            tmpLigne = ligneCourante[i]
            tmp = tryparse(Float64, tmpLigne)
            if typeof(tmp) == Nothing
            # ajout de la valeur courante
                mat[j,i] = valeurForCaractere(String(tmpLigne), mat, j, i)
            else
                mat[j,i] = tmp
            end
        end
    end

    # renvois de la matrice trouvée :
    return mat
end



# Fonction qui permet de passé d'un caractère à sa valeur associé dans la matrice
#
# @param le caractère à étudier
# @return la valeur associé
function valeurForCaractere(c::String, mat::Array{Float64,2}, j::Int64, i::Int64)
    if c == "-"
        return 0
    end
    return mat[i,j]
end
