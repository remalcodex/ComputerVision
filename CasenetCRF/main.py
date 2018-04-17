import networkx as nx
import matplotlib.pyplot as plt
import scipy.io
from PIL import Image
import numpy as np
from beliefpropogation import beliefpropogation


def main(w, h):
    # 360x640
    imWidth = 640
    imHeight = 360

    G = nx.Graph()
    createGraphFromImage(G, 640, 360)


    #------------------------ OLD code
    #createGraph(G, imWidth, imHeight)

    image = Image.new('RGB', (imWidth, imHeight))
    imagePix = image.load()

    for i in range(imHeight):
        for j in range(imWidth):
            imagePix[j, i] = (0, 0, 0)

    mat = scipy.io.loadmat('loop1_casenet_features/loop1_casenet_features/VDO_0017_1298.mat')
    features = mat['feat']
    vShape = features.shape
    no_of_features = vShape[1]
    rows = vShape[0]

    # Pixel value with labels.
    for j in range(rows):
        row = features[j]
        y = int(row[0] * imHeight)
        x = int(row[1] * imWidth)
        imagePix[x, y] = (255, 255, 255)
        #for i in range(no_of_features):
            #print(int(row[0]*imWidth), int(row[1]*imHeight))
    image.show()
    print('yes')

def createGraphFromImage(G, w, h):
    mat = scipy.io.loadmat('loop1_casenet_features/loop1_casenet_features/VDO_0017_1298.mat')
    features = mat['feat']
    vShape = features.shape
    no_of_features = vShape[1]
    rows = vShape[0]

    # Adding value nodes.
    for j in range(rows):
        row = features[j]
        G.add_node(j, bipartite = 0)

    # Calculating unary costs.
    unary_cost = []
    for j in range(rows):
        row = features[j]
        cost = row[2:]
        unary_cost.append(cost)


    # #Adding factor nodes.
    # messages = {}
    # offset = rows
    # count = 0
    # for i in range(rows):
    #     row = features[i]
    #     x = row[0] * w
    #     y = row[1] * h
    #     pos = np.array([x,y])
    #     for j in range(rows):
    #         if i != j:
    #             rowj = features[j]
    #             xj = rowj[0] * w
    #             yj = rowj[1] * h
    #             posj = np.array([xj, yj])
    #             d = np.linalg.norm(pos - posj)
    #             if d < 2:
    #                 #Create the factor node.
    #                 #TODO: create dictionary to store the messages.
    #                 id = offset + count
    #                 G.add_node(id, bipartite=1)
    #                 G.add_edge(id, i)
    #                 G.add_edge(id, j)
    #
    #                 messages[str(id) + '-' + str(i)] = 0
    #                 messages[str(id) + '-' + str(j)] = 0
    #                 count += 1

    # Adding factor nodes.
    imageP = np.zeros((h, w), 'int')
    messages = {}
    for i in range(rows):
        row = features[i]
        y = int(row[0] * h)
        x = int(row[1] * w)
        imageP[y, x] = i

    offset = rows
    count = 0
    for i in range(h):
        for j in range(w):
            if imageP[i, j] != 0:
                remove_node = 1
                #Node to the right.
                if j < w-1 and imageP[i, j + 1] != 0:
                    id = offset + count
                    G.add_node(id, bipartite=1)
                    G.add_edge(id, imageP[i, j])
                    G.add_edge(id, imageP[i, j+1])
                    count += 1
                    createMessages(messages, str(id), str(imageP[i, j]))
                    createMessages(messages, str(id), str(imageP[i, j + 1]))
                    remove_node = 0

                #Node to the bottom.
                if i < h-1 and imageP[i + 1, j] != 0:
                    id = offset + count
                    G.add_node(id, bipartite=1)
                    G.add_edge(id, imageP[i, j])
                    G.add_edge(id, imageP[i + 1, j])
                    count += 1
                    createMessages(messages, str(id), str(imageP[i, j]))
                    createMessages(messages, str(id), str(imageP[i + 1, j]))
                    remove_node = 0

                # Node to the diagnol right.
                if i < h - 1 and j < w - 1 and imageP[i + 1, j + 1] != 0:
                    id = offset + count
                    G.add_node(id, bipartite=1)
                    G.add_edge(id, imageP[i, j])
                    G.add_edge(id, imageP[i + 1, j + 1])
                    count += 1
                    createMessages(messages, str(id), str(imageP[i, j]))
                    createMessages(messages, str(id), str(imageP[i + 1, j + 1]))
                    remove_node = 0

                # Noe to the diagnol left.
                if i < h - 1 and j > 0 and imageP[i + 1, j - 1] != 0:
                    id = offset + count
                    G.add_node(id, bipartite=1)
                    G.add_edge(id, imageP[i, j])
                    G.add_edge(id, imageP[i + 1, j - 1])
                    count += 1
                    createMessages(messages, str(id), str(imageP[i, j]))
                    createMessages(messages, str(id), str(imageP[i + 1, j - 1]))
                    remove_node = 0

                #Node to the right 2 pixels.
                if j < w-2 and imageP[i, j + 2] != 0:
                    id = offset + count
                    G.add_node(id, bipartite=1)
                    G.add_edge(id, imageP[i, j])
                    G.add_edge(id, imageP[i, j + 2])
                    count += 1
                    createMessages(messages, str(id), str(imageP[i, j]))
                    createMessages(messages, str(id), str(imageP[i, j + 2]))
                    remove_node = 0

                #Node to the bottom 2 pixels.
                if i < h-2 and imageP[i + 2, j] != 0:
                    id = offset + count
                    G.add_node(id, bipartite=1)
                    G.add_edge(id, imageP[i, j])
                    G.add_edge(id, imageP[i + 2, j])
                    count += 1
                    createMessages(messages, str(id), str(imageP[i, j]))
                    createMessages(messages, str(id), str(imageP[i + 2, j]))
                    remove_node = 0

                #Removing nodes without any factor nodes.
                if remove_node == 1:
                    G.remove_node(imageP[i, j])



    nx.write_gexf(G, './graph.gexf')
    nbrs = G.neighbors(23629)
    for nbr in nbrs:
        print(nbr)
        # nbrs1 = G.neighbors(nbr)
        # for nbr1 in nbrs1:
        #     print(nbr1)

    beliefpropogation(G, unary_cost, rows, count, messages)
    print('done!')

def createMessages(messages, str1, str2):
    messages[str1 + '-' + str2] = [0] * 19
    messages[str2 + '-' + str1] = [0] * 19
    return messages

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

