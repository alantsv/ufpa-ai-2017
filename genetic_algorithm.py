#!/usr/bin/python3

from random import randint, uniform

# This code is based in a genetic algorithm in prolog

# Parametrização 
NUM_BITS = 20
MUT_PROB = 0.20
POP_CROSS = 20
CROSS_PROB = 0.7

def rand():
  return uniform(0.0, 1.0)

def crossing_points():
  fst_point = randint(0, NUM_BITS)
  sec_point = randint(0, NUM_BITS)
  if fst_point < sec_point:
    return fst_point, sec_point
  if fst_point > sec_point:
    return sec_point, fst_point
  return crossing_points()

def zipper(xs, ys):
  if (xs == [] and ys == ""):
    return []
  xs[0] = str(xs[0])
  return [xs[0] + "-" + ys[0]] + zipper(xs[1:], ys[1:])

def clear(xs):
  if xs == []:
    return []
  return [xs[0].split("-")[1]] + clear(xs[1:])

def cross(fst_ind, snd_ind, fst_point, snd_point):
  end = len(fst_ind)
  return (sub_list(fst_ind,1,fst_point) + 
  sub_list(snd_ind, fst_point + 1, snd_point) + 
  sub_list(fst_ind, snd_point + 1, end))

def add_list(x, xs):
  if x in xs:
    return xs
  return [x] + xs

def crossover_aux(max_cross,pop, acc):
  if max_cross >= len(acc):
    return acc
  else:
    fst_ind = roll_roulette(pop)
    snd_ind =  roll_roulette(pop)
    fst_point, snd_point = crossing_points()
    if uniform(0.0, 1.0) <= CROSS_PROB:
      new_fst_ind = cross(fst_ind, snd_ind, fst_point, snd_point)
      new_snd_ind = cross(snd_ind, fst_ind, fst_point, snd_point)
    else:
      new_fst_ind = fst_ind
      new_snd_ind = snd_ind
    acc1 = add_list(new_fst_ind, acc)
    acc2 = add_list(new_snd_ind, acc1)
    crossover_aux(max_cross, pop, acc2)

def crossover(pop):
  return crossover_aux(POP_CROSS, pop, [])
    

def get_pop(valor, pop):
  ind, *rest = pop
  ind = ind.split("-")
  print(pop)
  print(valor)
  if float(ind[0]) >= valor:
    return ind[1]
  else:
    return get_pop(float(ind[0])-valor,rest)

def roll_roulette(pop):
  return get_pop(uniform(0.0, 1.0), pop)

def sub_list(list, start=1, end=-1):
  return list[start-1:end]

def mutation (ind_list):
  if ind_list == None:
    return
  else:
    ind, *resto = ind_list
    if uniform(0.0, 1.0)() < MUT_PROB:
      new_ind = mutation_aux(ind)
    else:
      new_ind = ind
    return new_ind + mutation(resto)

def mutation_aux(ind):
  fst_point, sec_point = crossing_points()
  new_ind = mutated(ind, fst_point)
  new_ind = mutated(new_ind, sec_point)
  return new_ind

def mutated(ind, point):
  if (ind[point] == 0):
    return sub_list(ind,1,point-1) + [1] + sub_list(ind, point+1,)
  else: 
    return sub_list(ind,1,point-1) + [0] + sub_list(ind, point+1,)
  

print(zipper([0.2,0.3], "ab"))
print(clear(["1-a","2-b","3-c"]))
print(crossing_points())
print(sub_list("abcdef", 1,5))
print(mutated([1,0,0,0,0,1],3))
print(cross("abcdefg","1234567",2,5))
print(roll_roulette(["0.3-c","0.2-a","0.5-b"]))

# if __name__ == "__main__":
#   print("Main started")
#   print(getCrossingPoints())
#   print(getSubList("abcdef",6,5))
