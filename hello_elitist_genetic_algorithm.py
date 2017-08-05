
"""
Baseado: 
Copyright (c) 2011 Colin Drake
"""

import random

#
# Variáveis Globais 
#

OPTIMAL     = "Hello world"
DNA_SIZE    = len(OPTIMAL)
POP_SIZE    = 200
GENERATIONS = 1000
mutation_chance = 100 # 1/mutation_chance
crossover_chance= 6 # 1/...

# Salva os dois melhores
def save_elite (items):
  fst_elite_ind, smaller_weight = items[0]
  for item, weight in items:
    if smaller_weight >= weight:
      smaller_weight = weight
      snd_elite_ind, fst_elite_ind = fst_elite_ind, item
  return fst_elite_ind, snd_elite_ind

def weighted_choice(items):
  # items = Pop = [(ind1, peso1), (ind2, peso2)..]
  # método da roleta
  # vai descontando os pesos até encontrar o menor 
  weight_total = sum((item[1] for item in items))
  n = random.uniform(0, weight_total)
  for item, weight in items:
    if n < weight: return item
    n = n - weight
  return item

def random_char():
  #   Return a ASCII: 32..126 
  return chr(int(random.randrange(32, 126, 1)))

def random_population():
  pop = []
  for i in range(POP_SIZE):
    dna = ""
    for c in range(DNA_SIZE):
      dna += random_char()
    pop.append(dna)
  return pop

#
# GA functions
#

def fitness(dna):
  #calcula a distancia da letra atual até a otima
  fitness = 0
  for c in range(DNA_SIZE):
    fitness += abs(ord(dna[c]) - ord(OPTIMAL[c]))
  if fitness == 0: return 1.0
  else: return 1.0/(fitness+1)

def mutate(dna):
  # tenta mudar cada um dos char, probalidade 1/mutation_chance
  
  dna_out = ""
  for c in range(DNA_SIZE):
    if int(random.randrange(1,mutation_chance,1)) == 1:
      dna_out += random_char()
    else:
      dna_out += dna[c]
  return dna_out

def crossover(dna1, dna2):
  if int(random.randrange(1,crossover_chance,1)) == 1:
      pos = int(random.random()*DNA_SIZE)
      return (dna1[:pos]+dna2[pos:], dna2[:pos]+dna1[pos:])
  else: return (dna1, dna2)
  
def main():
  population = random_population()

  # roda as gerações 
  for generation in range(GENERATIONS):
    if generation % 100 == 0:
      print ("Generation %s... Random sample: '%s'" % (generation, population[0]))
    w_population = []

    for individual in population:
      fitness_val = fitness(individual)
      pair = (individual, fitness_val)
      w_population.append(pair)

    # salva dois melhores  
    fst_elite_ind, snd_elite_ind = save_elite(w_population)
    
    from operator import itemgetter

    population = []
    for _ in range(int(POP_SIZE/2)):
      # Selection
      ind1 = weighted_choice(w_population)
      ind2 = weighted_choice(w_population)

      # Crossover
      
      ind1, ind2 = crossover(ind1, ind2)

      # Mutate and add back into the population.
      population.append(mutate(ind1))
      population.append(mutate(ind2))
    
    # Adiciona o dois melhores a lista
    population = population[:-2] + [fst_elite_ind] + [snd_elite_ind]
    
    # pega a população e ordena para testar o ótimo  
    wp=w_population
    wp.sort(key=itemgetter(1), reverse=True)
    wp0=wp[0]
    #print(wp0[0],wp0[1])

    # se encontra a meta sai 
    if wp0[1]== 1:
        print ("Encontrou o Ótimo:" ,  wp0[0],wp0[1])
        exit(0)
  
  wp=w_population
  wp.sort(key=itemgetter(1), reverse=True)
  wp0=wp[0]
  print ("O melhor ainda não ótimo:", wp0[0],wp0[1])
  exit(0)

#
# Gera a população e evolui ela
#

if __name__ == "__main__":
  main()
  exit(0)
  
  
