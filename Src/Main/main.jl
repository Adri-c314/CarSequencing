include("../Util/includes.jl")
include("../Util/lecture.jl")
using Dates
using DataFrames
using CSV
using Dates


function evaluation(instance::Array{Array{Int32,1},1},ratio::Array{Array{Int32,1},1},pbl::Int64,Hprio::Int32)
    col = instance[1][2]
    nbcol = 0
    Hpriofail=0
    Lpriofail=0
    evalrat = [Int32[]]
    nbrat = zeros(Int32,size(ratio)[1])
    for i in 1:size(ratio)[1]
        append!(evalrat,[zeros(Int64, ratio[i][2])])
    end
    popfirst!(evalrat)

    tmpi=1
    for n in instance

        tmprio = 1
        for eval in evalrat
            for i in 1:length(eval)
                #on reset quand on a regarde plus de x voitures avec x => y/x
                if mod(tmpi,ratio[tmprio][2]+i)==0
                    eval[i]=0
                end
                #on ajoute 1 si la vouture n a bien la prio
                if i<=tmpi
                    #faudra enlever le +2 et a ma place mettre (#Hprio -1)
                    if n[tmprio+Hprio-1]==1
                        eval[i]+=1
                    end
                end

                if eval[i]>ratio[tmprio][1]

                    if tmprio>3
                        Lpriofail+=1
                    else
                        Hpriofail+=1
                    end
                end
            end
            tmprio+=1
        end



        if n[2]!= col
            nbcol+=1
            col=n[2]
        end
        tmpi+=1
    end
    println(Lpriofail)
    println(Hpriofail)
    println(nbcol)
end

function tri_car(instance::Array{Array{Int32,1},1})
    instance = sort(instance, lt=(x,y)->isless(x[1], y[1]))
    return instance
end

function lecture()


    # Gestion de l'instance :
    instance = "A"
    reference = "022_3_4_RAF_EP_ENP"
    #reference = "039_38_4_RAF_EP_ch1"
    datas = lectureCSV(instance, reference)

    # Initialisation de la variable txt du fichier output :
    txt = string(
        "===================================================\n",
        "Etude de l'instance : ", instance, "\n",
        "Reference du dossier : ", reference, "\n",
        "A la date du : ", Dates.now(), "\n",
        "===================================================\n\n"
    )

    # Initialisation des données :
    vehicles = datas[1]
    oo = datas[2] #optimization_objectives
    pbl = datas[3] #paint_batch_limi
    ratio = datas[4]
    #=
    colnames = ["Date","Seqrank","Ident","Paint_Color","HPRC1","HPRC2","HPRC3","LPRC1","LPRC2"]#,"LPRC3","LPRC4","LPRC5","LPRC6"]
    names!(vehicles, Symbol.(colnames))
    colnames = ["rank","objective_name","tamere"]
    names!(oo, Symbol.(colnames))
    =#

    instance = [Int32[]]


    println(size(vehicles)[2])
    for i in 1:size(vehicles)[1]

        tmp = Int32[0]

        for ii in 1:(size(vehicles)[2]-3)

            append!(tmp,vehicles[i,ii+3])
        end

        append!(instance,[tmp])

    end
    a=0
    popfirst!(instance)

    rat = [Int32[]]
    for i in 1:size(ratio)[1]
        append!(rat,[Int32[0,0]])
        if i ==1
            popfirst!(rat)
        end
        tmp = ratio.Ratio[i]
        tmp = split(tmp,"/")
        rat[i][1]= parse(Int,tmp[1])
        rat[i][2]= parse(Int,tmp[2])
    end
    Hprio = 0

    for name in names(vehicles)[5:end]
        tmp =split(string(name),"")
        if tmp[1]=="H"
            Hprio+=1
        end
    end
    pbl = pbl.limitation[1]

    obj= [0,0,0]
    for i in 1:size(oo)[1]
        if oo[i,2] == "high_priority_level_and_easy_to_satisfy_ratio_constraints"
            obj[i]=2
        elseif oo[i,2] == "paint_color_batches"
            obj[i]=1
        elseif oo[i,2] == "low_priority_level_ratio_constraints"
            obj[i]=3
        end
    end


    return instance, rat,pbl,obj,Hprio
end

function dur(ratio::Array{Array{Int32,1},1},PI::Array{Array{Int32,1},1},pi::Array{Array{Int32,1},1},Hprio::Int32)
    tmp=0
    ## ici remplacer 3 par le nb de Hprio
    if (PI[1][2]==pi[1][2])
        return 1
    end
    for i in 1:Hprio
        tmp+= (ratio[i][1]/ratio[i][2])*((PI[i][1]-pi[i][1])/(PI[i][2]-pi[i][2]))
    end

    return tmp
end

function GreedyRAF(instance::Array{Array{Int32,1},1},ratio::Array{Array{Int32,1},1},pbl::Int64,Hprio::Int32)
    sz =size(instance)[1]
    pi = [Int32[0,0]]
    PI = [Int32[0,sz]]
    ## ici remplacer 3 par le nb de Hprio
    for i in 1:(Hprio-1)
        append!(PI,[[0,sz]])
        append!(pi,[[0,0]])
    end



    color=[0]
    for car in instance
        if car[2]>length(color)
            for i in 1:car[2]-length(color)
                color=hcat(color,[0])
            end
        end
        color[car[2]]+=1

        ## ici remplacer 3 par le nb de Hprio
        for i in 1:Hprio

            PI[i][1]+= car[2+i]

        end
    end


    tmpplace=1
    tmpcol=1
    tmpi = argmax(color)[2]
    println(tmpi)

    println(color)
    tmp=0
    for n in color
        tmp+=ceil(Int,n/pbl)
    end
    println(tmp)
    while sum(color)!=0 && tmpplace != size(instance)[1]+1
        if tmpcol==pbl && color[tmpi]!=0
            tmpi = argmax2(color,tmpi)
            tmpcol=0
        elseif color[tmpi]==0
            tmpi = argmax(color)[2]
            tmpcol=0
        end
        tmpdur=-1
        tmpduri=instance[1]
        for car in instance

            ## avec dur
            if car[1]==0 && car[2]==tmpi && color[tmpi]>0

                ## ici remplacer 3 par le nb de Hprio
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
        if  tmpcol==pbl

        elseif tmpduri[1]==0 && tmpduri[2]==tmpi && color[tmpi]>0
            tmpduri[1]=tmpplace
            tmpplace+=1
            tmpcol+=1
            color[tmpi]-=1
            for i in 1:3
                pi[i][1]+=tmpduri[2+i]
                pi[i][2]+=1
            end
        end




    end
    println(tmpplace)
    println(size(instance)[1])
    println(color)
    return tri_car(instance)
end

function argmax2(tmp::Array{Int32,2},nope::Int32)
    tmpii=1
    tmpmax=tmp[1]
    for i in 1:length(tmp)
        if tmpmax<tmp[i] && i!= nope
            tmpmax=tmp[i]
            tmpii=i
        end
    end

    return tmpii
end

function GreedyEP(instance::Array{Array{Int32,1},1},ratio::Array{Array{Int32,1},1},pbl::Int64,Hprio::Int32)

    sz =size(instance)[1]
    pi = [Int32[0,0]]
    PI = [Int32[0,sz]]
    ## ici remplacer 3 par le nb de Hprio
    for i in 1:(Hprio-1)
        append!(PI,[[0,sz]])
        append!(pi,[[0,0]])
    end


    for car in instance


        ## ici remplacer 3 par le nb de Hprio
        for i in 1:Hprio

            PI[i][1]+= car[2+i]

        end
    end
    color=0
    tmpplace=1
    println("ui")
    for i in 1:size(instance)[1]
        tmpdur=-1
        tmpduri=instance[1]
        for car in instance
            if car[1]==0
                ## ici remplacer 3 par le nb de Hprio
                for ii in 1:Hprio
                    pi[ii][1]+=car[2+ii]
                    pi[ii][2]+=1
                end
                tmpdurdur = dur(ratio,PI,pi,Hprio)

                if tmpdurdur>tmpdur
                    tmpduri=car
                    tmpdur=tmpdurdur

                elseif tmpdurdur==tmpdur && car[2]==color
                    tmpduri=car
                    tmpdur=tmpdurdur
                end

                for ii in 1:Hprio
                    pi[ii][1]-=car[2+ii]
                    pi[ii][2]-=1
                end
            end
        end
        tmpduri[1]=tmpplace
        tmpplace+=1
        color=tmpduri[2]
    end

    return tri_car(instance)
end






function main()
## Instance : les voitures avec [1]= leur place mais pas utlie en vrai
##            les voitures avec [2]= leurs couleurs
##            les voitures avec [3:3+Hprio]= leurs Hprio
##            les voitures avec [3+Hprio:]= leurs Lprio
## Ratio x/y: Les ratio avec [1] = x
##            Les ratio avec [2] = y
## pbl      : Le paint batch limit
## obj      : Les obj des l'ordre
## Hprio    : le nombre de Hprio
instance, ratio ,pbl,obj,Hprio = lecture()
println(Hprio)

evaluation(instance,ratio,pbl,Hprio)

instance = GreedyRAF(instance,ratio,pbl,Hprio)
evaluation(instance,ratio,pbl,Hprio)
end
