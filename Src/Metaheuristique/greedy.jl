# Fichier tous les algorithms gloutons et leurs foncions associées
# @author Oryan Rampon
# @author Corentin Pelhatre
# @author Mathis Ocquident
# @author Thaddeus Leonard
# @author Adrien Cassaigne
# @author Xavier Pillet
# @date 01/11/2019
# @version 1



# Fonction qui realise l'algorithm glouton RAF
# @param instance : l'instance
# @param ratio : le tableau de ratio
# @param pbl : l'entier de paint_batch_limi
# @param Hprio : l'entier de H
# @return ::Array{Array{Int,1},1} : La nouvelle instance (avec un petit tri en plus pas piqué des annetons mais là je m'enballe peut etre un peu dans les commentaires apres je ne sais pas)
function GreedyRAF(instance::Array{Array{Int,1},1},sequence_j_avant::Array{Array{Int,1},1},ratio::Array{Array{Int,1},1},pbl::Int,Hprio::Int)
    sz =size(instance)[1]
    szcar = size(instance[1])[1]
    pi = [Int[0,0] for i in 1:Hprio]
    PI = [Int[0,sz] for i in 1:Hprio]

    # Tentative de correction mais confronter à un bug entre le typage Array{Array{Int,1},1} et Array{Int,2}
    color=Int[0]

    for car in instance
        if car[2]>length(color)
            for i in 1:car[2]-length(color)
                color=hcat(color,[0])
            end
        end
        color[car[2]]+=1
        for i in 1:Hprio
            PI[i][1]+= car[2+i]
        end
    end

    tmpplace=1
    tmpdebcol=tmpplace
    tmpcol=0
    tmpi = argmax(color)[2]
    tmp=0
    nbcol = 0
    for n in color
        tmp+=ceil(Int,n/pbl)
        nbcol+=1
    end
    if color[tmpi]>pbl
        mm = tmpplace+pbl-1
    else
        mm = tmpplace+color[tmpi]-1
    end
    tmpfincol=mm

    if color[tmpi]/pbl<= sum(color)-color[tmpi]+1
        while sum(color)!=0 && tmpplace <= size(instance)[1]
            block = [ceil(color[i]/pbl) for i in 1:nbcol]
            if  tmpcol>=pbl && tmpi == argmax(color)[2] && block[tmpi]> sum(block)-block[tmpi]
                tmpi = argmax2(convert(Array{Int,2},color),convert(Int,tmpi))
                tmpcol=0
                tmpdebcol=tmpplace
                tmpfincol=tmpplace
            elseif tmpdebcol==tmpfincol && block[argmax(color)[2]]> sum(block)-block[argmax(color)[2]]
                tmpi = argmax(color)[2]
                tmpcol=0
                tmpdebcol=tmpplace
                if color[tmpi]>pbl
                    mm = tmpplace+pbl-1
                else
                    mm = tmpplace+color[tmpi]-1
                end
                tmpfincol=mm
            elseif tmpcol>=pbl && color[tmpi]!=0
                tmpi = argmax2(convert(Array{Int,2},color),convert(Int,tmpi))
                tmpcol=0
                tmpdebcol=tmpplace
                if color[tmpi]>pbl
                    mm = tmpplace+pbl-1
                else
                    mm = tmpplace+color[tmpi]-1
                end
                tmpfincol=mm
            elseif color[tmpi]==0
                tmpi = argmax(color)[2]
                tmpcol=0
                tmpdebcol=tmpplace
                if color[tmpi]>pbl
                    mm = tmpplace+pbl-1
                else
                    mm = tmpplace+color[tmpi]-1
                end
                tmpfincol=mm
            end
            tmpdur=-1
            ttt=1
            if tmpcol<pbl
                while instance[ttt][1]!=0

                    ttt+=1
                end
            else
                ok =true
                while ok
                    while instance[ttt][1]!=0

                        ttt+=1
                    end
                    if instance[ttt][2]!=color
                        ok = false
                    else
                        ttt+=1
                    end
                end
            end
            tmpduri = instance[ttt]

            for ii in 1:sz
                car = instance[ii]
                if car[1]==0 && car[2]==tmpi && color[tmpi]>0
                    for i in 1:Hprio
                        pi[i][1]+=car[2+i]
                        pi[i][2]+=1
                    end
                    tmpdurdur = dur(ratio,PI,pi,Hprio)
                    if tmpdurdur>tmpdur
                        tmpduri=car
                        tmpdur=tmpdurdur

                    end
                    for i in 1:Hprio
                        pi[i][1]-=car[2+i]
                        pi[i][2]-=1
                    end
                end
            end

            if  tmpcol>=pbl
            elseif tmpduri[1]==0 && tmpduri[2]==tmpi && color[tmpi]>0
                tmpduri[1]=tmpplace
                tmpduri[szcar-1]=tmpfincol
                tmpduri[szcar-2]=tmpdebcol
                tmpplace+=1
                tmpcol+=1
                color[tmpi]-=1
                for i in 1:Hprio
                    pi[i][1]+=tmpduri[2+i]
                    pi[i][2]+=1
                end
            else
                debb=false
            end
        end
    end
    return tri_car(instance)
end



# Fonction qui realise l'algorithm glouton EP
# @param instance : l'instance
# @param ratio : le tableau de ratio
# @param pbl : l'entier de paint_batch_limi
# @param Hprio : l'entier de H
# @return ::Array{Array{Int,1},1} : la nouvelle instance
function GreedyEP(instance::Array{Array{Int,1},1},sequence_j_avant::Array{Array{Int,1},1},ratio::Array{Array{Int,1},1},pbl::Int,Hprio::Int)
    szcar = size(instance[1])[1]
    sz =size(instance)[1]

    pi = [Int[0,0] for i in 1:size(ratio)[1]]
    PI = [Int[0,sz] for i in 1:size(ratio)[1]]

    tmpdebcol=1
    for car in instance
        for i in 1:Hprio
            PI[i][1]+= car[2+i]
        end
    end

    tmppbl=1
    color=0
    tmpplace=1

    sz_avant =size(sequence_j_avant)[1]
    tmpavant = sz_avant
    tmpduri=instance[1]
    while tmpplace<=sz
        tmpdur=-10000
        for ii in 1:size(instance)[1]
            car = instance[ii]
            if car[1]==0
                for ii in 1:size(ratio)[1]
                    pi[ii][1]+=car[2+ii]
                    pi[ii][2]+=1
                end
                tmpdurdur = dur(ratio,PI,pi,Hprio)
                if  tmpdurdur>tmpdur && (tmppbl<pbl ||  car[2]!=color)
                    tmpduri=car
                    tmpdur=tmpdurdur
                elseif tmpdurdur==tmpdur && (car[2]!=color || tmppbl<=pbl)
                    tmpduri=car
                    tmpdur=tmpdurdur
                end
                for ii in 1:size(ratio)[1]
                    pi[ii][1]-=car[2+ii]
                    pi[ii][2]-=1
                end
            end
        end
        if tmpplace>1 && color != tmpduri[2]
            tmpdebcol = tmpplace
        end
        if color == tmpduri[2]
            tmppbl +=1
        else
            tmppbl = 1
        end
        tmpduri[1]=tmpplace
        tmpduri[szcar-2]=tmpdebcol
        tmpplace+=1
        color=tmpduri[2]
        for ii in 1:size(ratio)[1]
            pi[ii][1]-=tmpduri[2+ii]
            pi[ii][2]-=1
        end
    end
    for ii in 1:size(instance)[1]
        if instance[ii][1]==0
            for iii in 1:size(instance)[1]
                instance[iii][1]=0
            end
            return GreedyRAF(instance,sequence_j_avant,ratio,pbl,Hprio)
        end
    end

    instance =tri_car(instance)
    tmpi = sz
    tmpfincol = sz
    col = 0

    for i in 1:sz
        if col != instance[tmpi][2]
            tmpfincol = tmpi
            col = instance[tmpi][2]
        end
        instance[tmpi][szcar-1] = tmpfincol
        tmpi-=1
    end
    return instance
end



# Fonction qui tri l'instance
# @param instance : l'instance avant tri
# @return ::Array{Array{Int,1},1} : l'instance apres tri
function tri_car(instance::Array{Array{Int,1},1})
    instance = sort(instance, lt=(x,y)->isless(x[1], y[1]))
    return instance
end



# Fonction qui fait un truc bien utile
# @param tmp : Bah comme son nom l'indique elle doit pas duré tres longtemps donc bon..
# @param nope : nope !
# @return ::Int : Une vaste fumisterie
function argmax2(tmp::Array{Int,2},nope::Int)
    tmpii=1
    tmpmax=-1

    for i in 1:length(tmp)
        if tmpmax<tmp[i] && i!= nope
            tmpmax=tmp[i]
            tmpii=i
        end
    end
    return tmpii

end



# Fonction qui realise une chose dur !
# @param ratio : le tableau de ratios
# @param PI : Je sais pas d'ou il sort lui
# @param pi : et son fils c'est ramener avec
# @param Hprio : l'entier de h
# @return ::{Int} : un nombre mega dur à calculer même pas tu essaye.
function dur(ratio::Array{Array{Int,1},1},PI::Array{Array{Int,1},1},pi::Array{Array{Int,1},1},Hprio::Int)
    tmp=0

    if (PI[1][2]==pi[1][2])
        return 1
    end

    for i in 1:Hprio
        tmp+= (ratio[i][1]/ratio[i][2])*((PI[i][1]-pi[i][1])/(PI[i][2]-pi[i][2]))
    end

    return tmp
end
