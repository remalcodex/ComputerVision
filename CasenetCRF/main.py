import networkx as nx
import matplotlib.pyplot as plt
import scipy.io as sio
from PIL import Image
import numpy as np
from beliefpropogation import beliefpropogation


def main(w, h):

    label_colors={}
    label_colors[0] = (225, 0, 0)
    label_colors[1] = (0, 225, 0)
    label_colors[2] = (0, 0, 225)
    label_colors[3] = (255, 255, 0)
    label_colors[4] = (255, 0, 255)
    label_colors[5] = (0, 255, 255)
    label_colors[6] = (210, 5, 72)
    label_colors[7] = (19, 247, 11)
    label_colors[8] = (123, 119, 36)
    label_colors[9] = (159, 85, 192)
    label_colors[10] = (255, 255, 255)
    label_colors[11] = (138, 98, 200)
    label_colors[12] = (199, 188, 112)
    label_colors[13] = (196, 95, 124)
    label_colors[14] = (187, 136, 121)
    label_colors[15] = (28, 191, 140)
    label_colors[16] = (87, 126, 40)
    label_colors[17] = (83, 13, 83)
    label_colors[18] = (207, 147, 86)
    label_colors[19] = (48, 85, 62)

    G = nx.Graph()
    createGraphFromImage(G, 640, 360, label_colors)

    #------------------------ OLD code
    #createGraph(G, imWidth, imHeight)

    print('yes')

def createGraphFromImage(G, w, h, label_colors):
    mat = sio.loadmat('loop1_casenet_features/loop1_casenet_features/VDO_0018_3878.mat')    
    features = mat['feat']
    features = preprocess_features(features) #Preprocessing the features.
    vShape = features.shape
    no_of_features = vShape[1]
    rows = vShape[0]

    #Getting base labels
    defaultG = visualize_image(label_colors, features)

    # Adding value nodes and beliefs.
    beliefs_sum = {}
    beliefs = np.zeros((rows, 1), 'int')
    for j in range(rows):
        #row = features[j]
        #G.add_node(j, bipartite=0)
        beliefs_sum[j] = np.zeros((19, 1), dtype=object)

    # Calculating unary costs.
    unary_cost = []
    for j in range(rows):
        row = features[j]
        cost = row[2:]
        cost = cost.reshape(cost.shape[0], -1)
        unary_cost.append(cost)

    # Adding factor nodes.
    imageP = np.zeros((h, w), 'int')
    messages = {}
    for i in range(rows):
        row = features[i]
        y = int(round(row[0] * h))
        x = int(round(row[1] * w))
        if i == 0:
            imageP[y, x] = -1
        else:
            imageP[y, x] = i

    v_indexes = []
    #Adding variable nodes.
    for i in range(h):
        for j in range(w):
            if imageP[i, j] != 0:
                val = imageP[i, j]
                if val == -1:
                    val = 0
                G.add_node(val, bipartite=0)
                v_indexes.append(val)


    removed_vnodes = []
    offset = rows
    count = 0
    for i in range(h):
        for j in range(w):
            if imageP[i, j] != 0:
                c_val = imageP[i, j]
                if c_val == -1:
                    c_val = 0
                #Node to the right.
                if j < w-1 and imageP[i, j + 1] != 0:
                    id = offset + count
                    G.add_node(id, bipartite=1)
                    G.add_edge(id, c_val)
                    G.add_edge(id, imageP[i, j+1])
                    count += 1
                    createMessages(messages, str(id), str(c_val))
                    createMessages(messages, str(id), str(imageP[i, j + 1]))

                #Node to the bottom.
                if i < h-1 and imageP[i + 1, j] != 0:
                    id = offset + count
                    G.add_node(id, bipartite=1)
                    G.add_edge(id, c_val)
                    G.add_edge(id, imageP[i + 1, j])
                    count += 1
                    createMessages(messages, str(id), str(c_val))
                    createMessages(messages, str(id), str(imageP[i + 1, j]))

                # Node to the diagnol right.
                if i < h - 1 and j < w - 1 and imageP[i + 1, j + 1] != 0:
                    id = offset + count
                    G.add_node(id, bipartite=1)
                    G.add_edge(id, c_val)
                    G.add_edge(id, imageP[i + 1, j + 1])
                    count += 1
                    createMessages(messages, str(id), str(c_val))
                    createMessages(messages, str(id), str(imageP[i + 1, j + 1]))

                # Noe to the diagnol left.
                if i < h - 1 and j > 0 and imageP[i + 1, j - 1] != 0:
                    id = offset + count
                    G.add_node(id, bipartite=1)
                    G.add_edge(id, c_val)
                    G.add_edge(id, imageP[i + 1, j - 1])
                    count += 1
                    createMessages(messages, str(id), str(c_val))
                    createMessages(messages, str(id), str(imageP[i + 1, j - 1]))

                #Node to the right 2 pixels.
                if j < w-2 and imageP[i, j + 2] != 0:
                    id = offset + count
                    G.add_node(id, bipartite=1)
                    G.add_edge(id, c_val)
                    G.add_edge(id, imageP[i, j + 2])
                    count += 1
                    createMessages(messages, str(id), str(c_val))
                    createMessages(messages, str(id), str(imageP[i, j + 2]))

                #Node to the bottom 2 pixels.
                if i < h-2 and imageP[i + 2, j] != 0:
                    id = offset + count
                    G.add_node(id, bipartite=1)
                    G.add_edge(id, c_val)
                    G.add_edge(id, imageP[i + 2, j])
                    count += 1
                    createMessages(messages, str(id), str(c_val))
                    createMessages(messages, str(id), str(imageP[i + 2, j]))

                #Removing nodes without any factor nodes.
                if checkNeighborhood(imageP, i, j, w, h) == 0:
                    G.remove_node(c_val)
                    removed_vnodes.append(c_val)
                    v_indexes.remove(c_val)



    nx.write_gexf(G, './graph.gexf')

    # nbrs = G.neighbors(55)
    # for nbr in nbrs:
    #     print(nbr)
    #     # nbrs1 = G.neighbors(nbr)
    #     # for nbr1 in nbrs1:
    #     #     print(nbr1)
    #
    # print('fuck')
    nbrs = G.neighbors(112)
    for nbr in nbrs:
        s = str(nbr)
        nbrs1 = G.neighbors(nbr)
        for nbr1 in nbrs1:
            s = s + '-' + str(nbr1)
        print(s)

    #rows will be greater than v_indexes.
    print(v_indexes[len(v_indexes)-1])
    beliefpropogation(G, beliefs, beliefs_sum, unary_cost, v_indexes, rows, count, messages, removed_vnodes, features, label_colors, defaultG)
    print('done!')

def createMessages(messages, str1, str2):
    messages[str1 + '-' + str2] = np.zeros((19, 1), dtype=object)
    messages[str2 + '-' + str1] = np.zeros((19, 1), dtype=object)
    return messages

def checkNeighborhood(imageP, i, j, w, h):
    if j < w-1 and imageP[i, j+1] != 0:
        return 1
    if j < w-2 and imageP[i, j+2] != 0:
        return 1
    if i < h-1 and imageP[i+1, j] != 0:
        return 1
    if i < h-2 and imageP[i+2, j] != 0:
        return 1
    if j > 0 and imageP[i, j-1] != 0:
        return 1
    if j > 1 and imageP[i, j-2] != 0:
        return 1
    if i > 0 and imageP[i-1, j] != 0:
        return 1
    if i > 1 and imageP[i-2, j] != 0:
        return 1
    if i < h-1 and j < w-1 and imageP[i+1, j+1] != 0:
        return 1
    if i < h-1 and j > 0 and imageP[i+1, j-1] != 0:
        return 1
    if i > 0 and j < w-1 and imageP[i-1, j+1] != 0:
        return 1
    if i > 0 and j > 0 and imageP[i-1, j-1] != 0:
        return 1
    return 0

def visualize_image(label_colors, features):
    defaultG = []
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
        f_array = features[j]
        f_array_np = np.array(f_array[2:])
        idx = np.argmin(f_array_np)
        val = label_colors[idx]
        defaultG.append(idx)
        imagePix[x, y] = val
        # for i in range(no_of_features):
        # print(int(row[0]*imWidth), int(row[1]*imHeight))
    #image.show()
    image.save('./Outputs/00.jpg')
    defaultG = np.array(defaultG)
    return defaultG

def preprocess_features(features):
    vShape = features.shape
    no_of_features = vShape[1]
    rows = vShape[0]
    featuresL = np.empty((0,21), 'double')
    for j in range(rows):
        f_vals = features[j]
        probabilities = f_vals[2:]
        m_val = np.argmax(probabilities)
        if m_val >= 0.5:
            featuresL = np.vstack((featuresL, f_vals))

    rows = featuresL.shape[0]
    for j in range(rows):
        f_vals = featuresL[j]
        probabilities = f_vals[2:]
        probabilities = 1 - probabilities
        probabilities = probabilities*10
        f_vals[2:] = probabilities
        featuresL[j] = f_vals

    return featuresL


def createGraph(G, w, h):
    for i in range(h):
        for j in range(w):
            id = i*w + j
            G.add_node(id, bipartite=0)

    #Adding horizontal nodes
    offsetH = w*h
    for i in range(h):
        for j in range(w-1):
            id = offsetH + i*(w-1) + j #TODO: This should be w-1 maybe.
            G.add_node(id, bipartite=1)

            gid = i*w + j
            G.add_edge(id, gid)
            G.add_edge(id, gid+1)

    #Adding vertical nodes.

    offsetV = offsetH + (w-1)*h
    for i in range(h-1):
        for j in range(w):
            id = offsetV + i*w + j
            G.add_node(id, bipartite=1)

            gid = i*w + j
            G.add_edge(id, gid)
            G.add_edge(id, gid + w)

    offsetD = offsetV + (h-1)*w
    for i in range(h-1):
        for j in range(w-1):
            id = offsetD + i*(w-1) + j
            G.add_node(id, bipartite=1)

            gid = i*w+j
            G.add_edge(id, gid)
            G.add_edge(id, gid+1)
            G.add_edge(id, gid+w)
            G.add_edge(id, gid+w+1)

    #Adding distance 2 edges horizontal.
    offset2H = offsetD + (h-1)*(w-1)
    for i in range(h):
        for j in range(w-2):
            id = offset2H + i*(w-2) + j
            G.add_node(id, bipartite=1)

            gid = i*w+j
            G.add_edge(id, gid)
            G.add_edge(id, gid+2)

    # Adding distance 2 edges vertical.
    offset2V = offset2H + (h) * (w - 2)
    for i in range(h-2):
        for j in range(w):
            id = offset2V + i*w + j
            G.add_node(id, bipartite=1)

            gid = i*w + j
            G.add_edge(id, gid)
            G.add_edge(id, gid + w + w)

    #Adding distance 2 edges diagnol.
    offset2D = offset2V + (h-2)*w
    nx.write_gexf(G, './graph.gexf')
    return G


if __name__ == '__main__':
    main(5, 5)

