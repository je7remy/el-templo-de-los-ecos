extends RefCounted
## Conversaciones al entrar en las salas. Separadas del código del juego
## (scripts/main.gd) para editarlas sin tocar la lógica. Los pisos y sus salas
## están en datos/pisos/ (piso_NN.tres y piso_NN/sala_N.tres).

## Conversaciones al entrar en salas con más personajes. «{yo}» es tu nombre.
## Un tercer campo «solo» o «grupo» limita la línea a ir solo o acompañado.
const ROOM_TALKS := {
    "9:0": [
        ["HERMANO MAYOR", "Por fin. Eres {yo}, ¿verdad? Tu nombre está en el muro de los nombres, igual que el mío."],
        ["{yo}", "¿Quién eres?"],
        ["HERMANO MAYOR", "El que más tiempo lleva bajando. Los demás me llamaban Hermano Mayor. Ya no queda ninguno."],
        ["HERMANO MAYOR", "Más adelante hay una Puerta. Se abre con tres braseros encendidos, y yo no tengo fuego."],
        ["HERMANO MAYOR", "Tú sí. Enciéndelos y cruzaremos juntos."],
        ["{yo}", "Aquí abajo nadie hace nada por los demás."],
        ["HERMANO MAYOR", "Entonces hazlo por ti."],
    ],
    "9:3": [
        ["HERMANO MAYOR", "Los tres arden. Gracias, {yo}."],
        ["HERMANO MAYOR", "Pero el fuego solo despierta la Puerta. Para abrirse del todo pide almas. Muchas."],
        ["{yo}", "Las mías."],
        ["HERMANO MAYOR", "Cada piso me enseñó algo. Los hilos del cazador. La mirada de la que vigila."],
        ["HERMANO MAYOR", "Y esta máscara de porcelana. También la reponen para mí."],
    ],
    "1:0": [
        ["PEREGRINO", "¿Tú también despertaste aquí? {Tranquilo|Tranquila}, no muerdo."],
        ["{yo}", "¿Quién eres? ¿Cuánto llevas en este sitio?"],
        ["PEREGRINO", "Lo bastante para saber que las puertas de este piso solo se abren con almas."],
        ["PEREGRINO", "Busquemos juntos. Hay para los dos."],
    ],
    "1:1": [
        ["PEREGRINO", "Escucha el agua. Siempre baja... como nosotros."],
        ["{yo}", "Quédate donde pueda verte."],
        ["PEREGRINO", "Claro, claro. A tu lado."],
    ],
    "2:0": [
        ["ODÓN", "Otro más. Bien. La voz ya habló: hay que cazar al rápido."],
        ["BRUNA", "Lo llaman el Segador. Tensa hilos rojos antes de atacar. Vi cómo partía a un hombre en dos."],
        ["CIRO", "Yo... yo solo quiero bajar. Iré detrás de ti, si no te importa."],
        ["{yo}", "Detrás de mí es justo donde no quieres estar."],
        ["ODÓN", "Entonces marca tú el paso. Nosotros te seguimos."],
    ],
    "2:1": [
        ["BRUNA", "Ahí está. ¿Lo oyes? Cuerdas que se tensan."],
        ["ODÓN", "Los que lo cazaron antes no hablaban de su velocidad. Hablaban de sus hilos."],
        ["CIRO", "Y que la línea no nos pille a nosotros, por favor."],
    ],
    "4:0": [
        ["{yo}", "Ladridos sin aliento... Suenan a metal."],
        ["{yo}", "Y la antorcha chisporrotea más que arriba. Aquí se consume deprisa: tendré que medir los fósforos."],
    ],
    "5:0": [
        ["IRENE", "Alto. No traemos armas, mira. Solo queremos bajar."],
        ["TEO", "Te vimos cruzar el laberinto con la antorcha. Los perros te respetaban."],
        ["BAS", "Nosotros no sabemos leer este sitio. Tú sí."],
        ["SAÚL", "¡{yo}! Sigues {vivo|viva}. Les dije que volverías a aparecer."],
        ["IRENE", "Guíanos. Te seguiremos y no estorbaremos. Habla conmigo cuando lo decidas."],
    ],
    "5:1": [
        ["{yo}", "Un mercader... no dice nada. Hay una inscripción junto a la entrada.", "solo"],
        ["TEO", "Algo brilla bajo su manto. Solo quiero mirar..."],
        ["IRENE", "¡Teo, no!"],
        ["TEO", "¡AAAH! ¡Mi mano! ¡¿Dónde está mi mano?!"],
        ["IRENE", "Se paga primero. Y no se toca. Lo pone en la placa, Teo."],
        ["{yo}", "Nadie más acerca la mano a ese manto."],
    ],
    "5:3": [
        ["IRENE", "La escalera baja. Dicen que abajo hay algo que mira."],
        ["BAS", "Contigo delante, quizá lleguemos."],
        ["SAÚL", "Te debía una. Ahora te debo dos."],
    ],
    "7:0": [
        ["{yo}", "Esta sala... es la primera. El Umbral del despertar. Pero las estatuas miran al revés."],
        ["{yo}", "Y esa inscripción tiene mi nombre. ¿La escribí yo en otra vida?"],
    ],
    "7:1": [
        ["{yo}", "El ojo del muro. Lo conozco... o creo que lo conozco."],
    ],
    "8:2": [
        ["{yo}", "Es una estatua... y camina."],
        ["{yo}", "Cada vez que pisa, las columnas agrietadas tiemblan."],
    ],
    "6:0": [
        ["{yo}", "Ojos arrancados en cada estatua... Lo que vive aquí no soporta que la ignoren.", "solo"],
        ["IRENE", "Mira la inscripción. «Quien gritó, se quedó. Quien corrió, también.»"],
        ["BAS", "¿Y si nos mira a nosotros?"],
        ["{yo}", "Entonces nadie corre. Pase lo que pase.", "grupo"],
        ["SAÚL", "Contigo delante no correré. Lo prometo."],
    ],
    "6:1": [
        ["{yo}", "Ahí está. No parpadea.", "solo"],
        ["IRENE", "No le quitéis los ojos de encima. Ni un segundo."],
    ],
    "3:0": [
        ["{yo}", "Raíces secas por todas partes. Una chispa y esto arde entero."],
        ["{yo}", "Y las de la puerta están vivas... habrá que hacerles llegar el fuego."],
    ],
    "3:1": [
        ["{yo}", "Esa cosa es corteza... y aquí todo es leña."],
    ],
    "2:2": [
        ["CIRO", "Está herido... Esta vez no tiene adónde huir."],
        ["BRUNA", "Cuidado con las líneas, {yo}. Aquí hay muchas más."],
    ],
}
