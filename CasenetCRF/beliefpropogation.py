import numpy as np
import scipy.io
from PIL import Image
import pickle
import json

def beliefpropogation(G, beliefsG, beliefs_sum, unary_cost, v_indexes, vnodes, fnodes, messages, removed_vnodes, features, label_colors, defaultG):

    l_values = 19
    iterations = 20
    for iter in range(iterations):
        with open('./Outputs/' + str(iter) + '.pickle', 'wb') as handle:
            pickle.dump(messages, handle, protocol=0)
        # if iter >= 17:
        #     with open('./Outputs/' + str(iter) + '.json', 'w') as handle:
        #         handle.write(str(messages))
        print('Iteration: ' + str(iter))
        beliefsL = np.zeros(beliefsG.shape, 'int')
        #Messages from factor node to variable node.

        for f_id in range(vnodes, vnodes+fnodes):
            if f_id%100000 == 0:
                print('s: ' + str(vnodes) + ' c: ' + str(f_id) + ' e: ' + str(vnodes+fnodes))
            nbrs = G.neighbors(f_id)
            v_id1 = 0
            v_id2 = 0
            count = 0
            for nbr in nbrs:
                if count == 0:
                    v_id1 = nbr
                else:
                    v_id2 = nbr
                count += 1
            messages[str(f_id) + '-' + str(v_id1)] = findMinimum(l_values, v_id2, f_id, messages, 10)
            messages[str(f_id) + '-' + str(v_id2)] = findMinimum(l_values, v_id1, f_id, messages, 10)

        #Updating beliefs.
        for v_id in v_indexes:
            if v_id in removed_vnodes:
                continue
            dummy = np.zeros((19, 1), 'float')
            nbrs = G.neighbors(v_id)
            for f_id in nbrs:
                dummy = dummy + messages[str(f_id) + '-' + str(v_id)]
            #Adding the unary cost now.
            dummy = dummy + unary_cost[v_id]
            beliefs_sum[v_id] = dummy

        # if iter >= 17:
        #     with open('./Outputs/' + str(iter) + '_beliefs_sum.json', 'w') as handle:
        #         handle.write(str(beliefs_sum))

        #Taking prediction.
        for v_id in v_indexes:
            if v_id in removed_vnodes:
                continue
            v_array = beliefs_sum[v_id]
            idx = np.argmin(v_array)
            beliefsL[v_id] = idx

        #Checkif label has changed
        if np.array_equal(beliefsG,beliefsL):
            print('Labels are not changing.')
            break
        else:
            beliefsG = beliefsL

        visualize_data(beliefsG, features, iter, label_colors, defaultG)
        #Updating the messages from variable node to factor node.
        for v_id in v_indexes:
            if v_id in removed_vnodes:
                continue
            nbrs = G.neighbors(v_id)
            for f_id in nbrs:
                val = beliefs_sum[v_id] - messages[str(f_id) + '-' + str(v_id)]
                messages[str(v_id) + '-' + str(f_id)] = val

    print('yes')

def findMinimum(l_values, v_node, f_node, messages, lamda):
    finalV = np.zeros((l_values, 1), 'float')
    m_cost = messages[str(v_node) + '-' + str(f_node)]
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
        finalV[i, 0] = minV
    return finalV


def visualize_data(beliefs, features, iter, label_colors, defaultG):
    defaultG = defaultG.reshape(defaultG.shape[0], -1)
    imWidth = 640
    imHeight = 360
    image = Image.new('RGB', (imWidth, imHeight))
    imagePix = image.load()

    for i in range(imHeight):
        for j in range(imWidth):
            imagePix[j, i] = (0, 0, 0)

    vShape = features.shape
    rows = vShape[0]

    # Pixel value with labels.
    for j in range(rows):
        row = features[j]
        y = int(round(row[0] * imHeight))
        x = int(round(row[1] * imWidth))
        idx = beliefs[j]
        val = label_colors[idx[0]]
        imagePix[x, y] = val
        # for i in range(no_of_features):
        # print(int(row[0]*imWidth), int(row[1]*imHeight))
    #image.show()
    image.save('./Outputs/' + str(iter) + '.jpg')
    find_cost(beliefs, defaultG)

def find_cost(beliefs, defaultG):
    count = 0
    for j in range(beliefs.shape[0]):
        if beliefs[j] != defaultG[j]:
            count += 1
    print('Cost= ' + str(count))