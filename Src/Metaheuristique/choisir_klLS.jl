# Fichier contenant toutes les fonctions necessaires au choix de klLS
# @author Xavier Pillet
# @author Mathis Ocquident
# @date 01/11/2019
# @version 1



using Random



# Fonction pour choisir k, l et l'algo de recherche local, par pas Xavier.
# Cette fonction determine les entiers k et l d'ou sont applique la recherche locale, ainsi que l'algo de recherche locale a utiliser.
# k et l dependant de si on utilise OptA, OptB ou OptC et aussi de la sequence_courante (pour savoir ou sont les blocks de couleur).
# @param sequence_courante : La sequence ou instance courrante
# @param opt::Symbol : doit appartenir :OptA, :OptB, :OptC.
## du coup oui mais pas vraiment # @return LSfoo!::Function : LSfoo! doit etre une des fonctions de recherche locale (swap!, fw_insertion!, bw_insertion!, reflection!, permutation!). Retourne les bonnes valeurs de k et de l en fonction de si on applique OptA, OptB ou OptC.
# @return ID_rand[mv][i]::Function : une fonction pour obtenir k et l random
# @return ID_LS[mv]::Function : une fonction de recherche locale
function choisir_klLS(sequence_courrante::Array{Array{Int,1},1}, opt::Array{Int,1},obj::Array{Int,1},phase::Int)
    ID_LS = (:swap!, :insertion!, :reflection!, :shuffle!)
    ID_rand1 = (:generic!, :similar!, :consecutive!, :same_color!,:border_block_two!,:violation!,:violation_same_color!)
    ID_rand2 = (:generic!, :denominator!, :same_color!, :border_block_one!)
    ID_rand3 = (:generic!, :denominator!, :same_color!, :border_block_one!,:border_block_two!)
    ID_rand4 = (:generic!,:generic!)
    ID_rand=[ID_rand1,ID_rand2,ID_rand3,ID_rand4]
    opt[phase]
    OptA = [72,88,99,100]
    OptB = [43,81,99,100]
    OptC = [40,64,99,100]
    OPT = [OptA,OptB,OptC]
    if opt[phase]!=0
        mouv = OPT[opt[phase]]
        a = rand(1:100,1)[1]
        if a < mouv[1]
            mv = 1
        elseif a < mouv[2]
            mv = 2
        elseif a < mouv[3]
            mv = 3
        else
            mv = 4
        end

        movA = [[66,68,70,70,70,72,72],[80,88,88,88],[95,99,99,99,99],[100]]
        movB = [[18,18,22,30,40,42,43],[43,43,73,81],[81,81,89,95,99],[100]]
        movC = [[0,0,5,30,35,35,40],[40,40,52,64],[64,64,74,84,99],[100]]
        #movA = [[66,68,70,70,72,72,72],[80,88,88,88],[95,99,99,99,99],[100]]
        #movB = [[18,18,22,30,43,43,43],[43,43,73,81],[81,81,89,95,99],[100]]
        #movC = [[0,0,5,30,40,40,40],[40,40,52,64],[64,64,74,84,99],[100]]

        mov = [movA,movB,movC]
        i=1
        while a > mov[opt[phase]][mv][i]
            i+=1
        end



        ## je return la fonction rand a utiliser et le moiv a faire.
        ##car je pense que la fonction rand a utiliser meme generic depans du mouv a faire et bref
        ##
        return ID_rand[mv][i],ID_LS[mv]
    else
        return :generic!,:swap!
    end
end


function choisir_klLS(sequence_courrante::Array{Array{Int,1},1}, opt::Array{Int,1},obj::Array{Int,1},phase::Int)
    ID_LS = (:swap!, :insertion!, :reflection!, :shuffle!)
    ID_rand1 = (:generic!, :similar!, :consecutive!, :same_color!,:border_block_two!,:violation!,:violation_same_color!)
    ID_rand2 = (:generic!, :denominator!, :same_color!, :border_block_one!)
    ID_rand3 = (:generic!, :denominator!, :same_color!, :border_block_one!,:border_block_two!)
    ID_rand4 = (:generic!,:generic!)
    ID_rand=[ID_rand1,ID_rand2,ID_rand3,ID_rand4]
    opt[phase]
    OptA = [72,88,99,100]
    OptB = [43,81,99,100]
    OptC = [40,64,99,100]
    OPT = [OptA,OptB,OptC]
    if opt[phase]!=0
        mouv = OPT[opt[phase]]
        a = rand(1:100,1)[1]
        if a < mouv[1]
            mv = 1
        elseif a < mouv[2]
            mv = 2
        elseif a < mouv[3]
            mv = 3
        else
            mv = 4
        end

        movA = [[66,68,70,70,70,72,72],[80,88,88,88],[95,99,99,99,99],[100]]
        movB = [[18,18,22,30,40,42,43],[43,43,73,81],[81,81,89,95,99],[100]]
        movC = [[0,0,5,30,35,35,40],[40,40,52,64],[64,64,74,84,99],[100]]
        #movA = [[66,68,70,70,72,72,72],[80,88,88,88],[95,99,99,99,99],[100]]
        #movB = [[18,18,22,30,43,43,43],[43,43,73,81],[81,81,89,95,99],[100]]
        #movC = [[0,0,5,30,40,40,40],[40,40,52,64],[64,64,74,84,99],[100]]

        mov = [movA,movB,movC]
        i=1
        while a > mov[opt[phase]][mv][i]
            i+=1
        end



        ## je return la fonction rand a utiliser et le moiv a faire.
        ##car je pense que la fonction rand a utiliser meme generic depans du mouv a faire et bref
        ##
        return ID_rand[mv][i],ID_LS[mv]
    else
        return :generic!,:swap!
    end
end
