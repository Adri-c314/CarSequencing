a =evaluation(sequence_courante,tab_violation,ratio_option,col_avant,Hprio)
if a[obj[1]]>aa[obj[1]]
    println(tmp_Hprio)
    println(tmp_color)
    println(aa)
    println(a)
    println("faux positif")
    for i in k-10:l+10
        println(sequence_courante[i])
    end
            println(col_avant)
    println("k : ", k," l : ",l)
    return swap_obj_1
end

if a[obj[2]]>aa[obj[2]] && a[obj[1]]==aa[obj[1]]
    println(tmp_Hprio)
    println(tmp_color)
    println(aa)
    println(a)
    println("faux positif")
    for i in k:l
        println(sequence_courante[i])
    end
    println(col_avant)
    println("k : ", k," l : ",l)
    return swap_obj_2
end
col = sequence_courante[1][2]
deb = sequence_courante[1][szcar-2]
fin = sequence_courante[1][szcar-1]
for i in 1:1:size(sequence_courante)[1]

    if col !=  sequence_courante[i][2]
        col = sequence_courante[i][2]
        if fin+1 != sequence_courante[i][szcar-2]
            for car in sequence_courante
                println(car)
            end
            println("k : ",k, " l : ", l)
            println(sequence_courante[k])
            println(sequence_courante[l])
            println(i)
                    println(col_avant)
            return FAUX
        end
        deb = sequence_courante[i][szcar-2]
        fin = sequence_courante[i][szcar-1]
    else
        if fin != sequence_courante[i][szcar-1] || deb != sequence_courante[i][szcar-2]

            for car in sequence_courante
                println(car)
            end
            println("k : ",k, " l : ", l)
            println(sequence_courante[k])
            println(sequence_courante[l])
                    println(col_avant)
            return FAUXXXXX
        end
    end
    if deb<1 || fin >sz
        println("k : ",k, " l : ", l)
        println(sequence_courante[k])
        println(sequence_courante[l])
        println(i)
        println(sequence_courante[i])
                                println(col_avant)
        return FAUX_fin_ou_deb

    end
end




            #=
            a,b =evaluation_init(sequence_meilleure,sequence_avant,ratio_option,Hprio)

            for o in 1:size(b)[1]
                for oo in 1:size(b[o])[1]
                    if b[o][oo]!=tab_violation[o][oo]
                        println("pas bo")
                    end
                end
            end
            =#
