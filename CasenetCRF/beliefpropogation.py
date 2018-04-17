import numpy as np
def beliefpropogation(G, unary_cost, vnodes, fnodes, messages):

    l_values = 19
    iterations = 20
    for iter in range(iterations):

        #Messages from factor node to variable node.
        for id in range(vnodes, vnodes+fnodes):
            nbrs = G.neighbors(id)
            nbr1 = 0
            nbr2 = 0
            count = 0
            for nbr in nbrs:
                if count == 0:
                    nbr1 = nbr
                else:
                    nbr2 = nbr
            findMinimum(l_values, nbr1, id, messages, 1)

        # Updating beliefs.
        for id in range(vnodes):
            nbrs = G.neighbors(id)
            for nbr in nbrs:


    print('yes')

def findMinimum(l_values, nbr, f_node, messages, lamda):
    finalV = np.zeros(l_values, 1)
    m_cost = messages[str(f_node) + '-' + str(nbr)]
    for i in range(l_values):
        # Taking the minimum cost.
        costM = lamda
        if i == 0:
            costM = 0
        minV = costM + m_cost[0]

        for j in range(l_values):
            costV = lamda
            if i == j:
                costV = 0
            costV = costV + m_cost[j]
            if minV > costV:
                minV = costV
        finalV[i, 1] = minV
    return finalV

def findMinimum2(l_values, nbrL, nbrR, f_node, messages, lamda):
    finalV = np.zeros(l_values, 1)
    m_cost = messages[str(f_node) + '-' + str(nbrL)]
    for i in range(l_values):
        # Taking the minimum cost.
        costM = lamda
        if i == 0:
            costM = 0
        minV = costM + m_cost[0]

        for j in range(l_values):
            costV = lamda
            if i == j:
                costV = 0
            costV = costV + m_cost[j]
            if minV > costV:
                minV = costV
        finalV[i, 1] = minV
    return finalV