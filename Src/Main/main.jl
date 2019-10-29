include("../Util/includes.jl")

function main()
    #=
    ## Instance : les voitures avec [1]= leur place mais pas utlie en vrai
    ##            les voitures avec [2]= leurs couleurs
    ##            les voitures avec [3:3+Hprio]= leurs Hprio
    ##            les voitures avec [3+Hprio:]= leurs Lprio
    ##                              [size()[1]-2] = le debut de leur sequence de couleur
    ##                              [size()[1]-1] = la fin de leur sequence de couleur
    ## Ratio x/y: Les ratio avec [1] = x
    ##            Les ratio avec [2] = y
    ## pbl      : Le paint batch limit
    ## obj      : Les obj des l'ordre
    ## Hprio    : le nombre de Hprio
    instance, ratio ,pbl,obj,Hprio = lecture()
    sz=size(instance)[1]

    score_courrant , tab_violation = evaluation(instance,ratio,pbl,Hprio)

    instance = GreedyRAF(instance,ratio,pbl,Hprio)
    instance = GreedyEP(instance,ratio,pbl,Hprio)
    score_courrant , tab_violation = evaluation(instance,ratio,pbl,Hprio)
    for car in instance
        println(car)
    end
    k,l = denominator(instance,ratio,sz)
    =#
    instance = "A"
    #reference = "022_3_4_RAF_EP_ENP"
    reference = "039_38_4_RAF_EP_ch1"
    b = 0.0
    VFLS(instance,reference,b)

end
