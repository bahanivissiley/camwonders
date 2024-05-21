import 'package:camwonders/class/classes.dart';

final List<Categorie> cats = [
  Categorie(1, "Wonders nature", 'leaf'),
  Categorie(2, "Wonders restau", 'utensils'),
  Categorie(3, "Wonders Hotels", 'bed'),
  Categorie(4, "Wonders Patrimoine", 'landmark'),
];

final List<Wonder> wonders = [
  Wonder(1, "Les chutes Carrefour de la lobe", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris consequat consequat enim, non auctor massa ultrices non. Morbi sed odio massa. Quisque at vehicula tellus, sed tincidunt augue. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Maecenas varius egestas diam, eu sodales metus scelerisque congue. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Maecenas gravida justo eu arcu egestas convallis. Nullam eu erat bibendum, tempus ipsum eget, dictum enim. Donec non neque ut enim dapibus tincidunt vitae nec augue. Suspendisse potenti. Proin ut est diam. Donec condimentum euismod tortor, eget facilisis diam faucibus et. Morbi a tempor elit.", "assets/img1.jpg", "Yaounde", false, 10000, "24h/7j", 0.22, 1.23, 3, cats[0]),
  Wonder(2, "Carrefour  Carrefour j'aime Carrefour j'aime Carrefour j'aime Carrefour j'aime", "ceci est une description, description ceci est une description, descriptune description, description ceci est uune description, description ceci est une description, description cecne description, description cecune description, description ceci est une description, description cecion ceci est une description, description", "assets/img2.jpg", "Garoua", true, 0, "7h30-18h00", 0.22, 1.23, 4, cats[0]),
  Wonder(3, "Gorge de kola Gorge", "ceci est une description, description ceci est une description, description ceciune description, description ceci est unune description, description ceci est une description, description cece description, description cecune description, description ceci est une description, description cec est une description, description", "assets/img3.jpg", "Douala", false, 875000, "24h/7j", 0.22, 1.23, 4, cats[0]),
  Wonder(4, "Les chutes de lagdo", "ceci est une description, description ceci est une description, description ceci eune description, description ceci est unune description, description ceci est une description, description cece description, description cecune description, description ceci est une description, description cecst une description, description", "assets/img4.jpg", "Maroua", true, 0, "7h30-18h00", 0.22, 1.23, 4, cats[0]),

  Wonder(5, "Carrefour j'aime", "ceci est une description, description ceci est une description, description ceci est uneune description, description ceci est unune description, description ceci est une description, description cece description, description cecune description, description ceci est une description, description cec description, description", "assets/img5.jpg", "Yaounde", false, 500, "24h/7j", 0.22, 1.23, 3, cats[1]),
  Wonder(6, "Gorge de Carrefour kola", "ceci est une description, description ceci est une description, description ceci est uune description, description ceci esune description, description ceci est une description, description cect une description, description cecune description, description ceci est une description, description cecne description, description", "assets/img6.jpg", "Garoua", true, 0, "7h30-18h00", 0.22, 1.23, 1, cats[1]),
  Wonder(7, "Les chutes de la lobe", "ceci est une description, description ceci est une description, description ceci est une descune description, description ceune description, description ceci est une description, description cecci est une description, description cecune description, description ceci est une description, description cecription, description", "assets/img7.jpg", "Yaounde", false, 8450, "24h/7j", 0.22, 1.23, 1, cats[1]),
  Wonder(8, "Gorge Gorge de kola", "ceci est une description, description ceci est une description, description ceci est une descriptionune description, descriptionune description, description ceci est une description, description cec ceci est une description, description cecune description, description ceci est une description, description cecune description, description ceci est une description, description cec, description", "assets/img8.jpg", "Maroua", true, 0, "7h30-18h00", 0.22, 1.23, 4, cats[1]),

  Wonder(9, "Carrefomur j'aie", "ceci est une description, description ceci est une descrune description, description ceci est une description, description cecune descrune description, description ceci est une description, description ceciption, description ceci est une description, description ceciption, description ceci est une description, description", "assets/img1.jpg", "Bertoua", true, 0, "7h30-18h00", 0.22, 1.23, 4, cats[2]),
  Wonder(10, "Gorge de Carrefour kola Gorge", "ceci est une description, description ceci est une description, description cecune description, description ceci est une description, description cecune description, description ceci est une description, description ceci est une description, description", "assets/img2.jpg", "Ebolowa", true, 0, "7h30-18h00", 0.22, 1.23, 2, cats[2]),
  Wonder(11, "Les chutes de la lobe Gorge Gorge", "ceci est une description, description ceci est une description, description cune description, description ceci est une description, description cecune description, description ceci est une description, description cececi est une description, description", "assets/img3.jpg", "Douala", false, 400, "24h/7j", 0.22, 1.23, 5, cats[2]),
  Wonder(12, "Les chutes de la lobe", "ceci est une description, description ceci est une description, description ceci est une description,une description, description ceci est une description, description cecune description, description ceci est une description, description cec description", "assets/img4.jpg", "Yaounde", true, 0, "7h30-18h00", 0.22, 1.23, 4, cats[2]),

  Wonder(13, "Gorge Carrefour j'aime Gorge", "ceci est une description, description ceci est une description, description ceci est une description, descriptune description, description ceci est une description, description cecune description, description ceci est une description, description cecion", "assets/img6.jpg", "Yaounde", false, 7500, "7h30-18h00", 0.22, 1.23, 4, cats[3]),
  Wonder(14, "Les chutes de la lobe ", "ceci est une description, description une description, description ceci est une description, description cecune description, description ceci est une description, description cecceci est une description, description ceci est une description, description", "assets/img7.jpg", "Yaounde", true, 0, "7h30-18h00", 0.22, 1.23, 5, cats[3]),
  Wonder(15, "Les chutes Carrefour de la lobe", "ceci est une description, description ceci est une description, description ceci est une description, description cecune description, description ceci est une description, description cecune description, description ceci est une description, description", "assets/img8.jpg", "Yaounde", false, 100, "7h30-18h00", 0.22, 1.23, 3, cats[3]),
  Wonder(16, "Les Gorge chutes de la lobe", "ceci est une description, description ceci est une description, descriptiune description, description ceci est une description, description cecune description, description ceci est une description, description cecon ceci est une description, description", "assets/img9.jpg", "Yaounde", true, 0, "7h30-18h00", 0.22, 1.23, 2, cats[3]),
];

final List<AvantagesInconvenient> avIncs = [
  AvantagesInconvenient(1, true, "Acces tres facile", wonders[0]),
  AvantagesInconvenient(2, true, "Acces tres facile", wonders[1]),
  AvantagesInconvenient(3, true, "Acces tres facile", wonders[2]),
  AvantagesInconvenient(4, true, "Acces tres facile", wonders[3]),
  AvantagesInconvenient(5, false, "Pluviometrie assez instable", wonders[0]),
  AvantagesInconvenient(6, false, "Acces tres facile", wonders[1]),
  AvantagesInconvenient(7, false, "Acces tres facile", wonders[2]),
  AvantagesInconvenient(8, false, "Acces tres facile", wonders[3]),
  AvantagesInconvenient(9, false, "Acces tres facile", wonders[0]),
  AvantagesInconvenient(9, false, "Acces tres facile", wonders[1]),
  AvantagesInconvenient(1, false, "Acces tres facile", wonders[2]),
  AvantagesInconvenient(1, false, "Acces tres facile", wonders[3]),
  AvantagesInconvenient(1, false, "Acces assez chere", wonders[0]),
  AvantagesInconvenient(1, true, "Acces tres facile", wonders[1]),
  AvantagesInconvenient(1, true, "Acces tres facile", wonders[2]),
  AvantagesInconvenient(1, true, "Acces tres facile", wonders[3]),
  AvantagesInconvenient(1, true, "Service client bien professionnel", wonders[0]),
  AvantagesInconvenient(1, true, "Acces tres facile", wonders[3]),
  AvantagesInconvenient(1, true, "Acces tres facile", wonders[4]),
  AvantagesInconvenient(1, true, "Acces tres facile", wonders[5]),
  AvantagesInconvenient(1, true, "Acces tres facile", wonders[6]),
];

final List<Img> images = [
  Img(42, "assets/img8.jpg", wonders[0]),
  Img(1, "assets/img1.jpg", wonders[1]),
  Img(2, "assets/img2.jpg", wonders[2]),
  Img(3, "assets/img3.jpg", wonders[3]),
  Img(4, "assets/img4.jpg", wonders[4]),
  Img(5, "assets/img5.jpg", wonders[5]),
  Img(6, "assets/img6.jpg", wonders[6]),
  Img(7, "assets/img7.jpg", wonders[7]),
  Img(8, "assets/img1.jpg", wonders[8]),

  Img(9, "assets/img9.jpg", wonders[1]),
  Img(10, "assets/img10.jpg", wonders[2]),
  Img(11, "assets/img11.jpg", wonders[3]),
  Img(12, "assets/img12.jpg", wonders[4]),
  Img(13, "assets/img13.jpg", wonders[5]),
  Img(14, "assets/img7.jpg", wonders[6]),
  Img(15, "assets/img15.jpg", wonders[7]),
  Img(16, "assets/img16.jpg", wonders[8]),
  Img(41, "assets/img7.jpg", wonders[0]),

  Img(17, "assets/img17.jpg", wonders[1]),
  Img(18, "assets/img18.jpg", wonders[2]),
  Img(19, "assets/img1.jpg", wonders[3]),
  Img(20, "assets/img2.jpg", wonders[4]),
  Img(21, "assets/img3.jpg", wonders[5]),
  Img(22, "assets/img4.jpg", wonders[6]),
  Img(23, "assets/img1.jpg", wonders[7]),
  Img(24, "assets/img2.jpg", wonders[8]),
  Img(43, "assets/img3.jpg", wonders[0]),

  Img(25, "assets/img3.jpg", wonders[1]),
  Img(26, "assets/img4.jpg", wonders[2]),
  Img(27, "assets/img1.jpg", wonders[3]),
  Img(28, "assets/img2.jpg", wonders[4]),
  Img(29, "assets/img3.jpg", wonders[5]),
  Img(30, "assets/img4.jpg", wonders[6]),
  Img(31, "assets/img1.jpg", wonders[7]),
  Img(32, "assets/img2.jpg", wonders[8]),
  Img(44, "assets/img8.jpg", wonders[0]),

  Img(33, "assets/img3.jpg", wonders[1]),
  Img(34, "assets/img4.jpg", wonders[2]),
  Img(35, "assets/img1.jpg", wonders[3]),
  Img(36, "assets/img2.jpg", wonders[4]),
  Img(37, "assets/img3.jpg", wonders[5]),
  Img(38, "assets/img4.jpg", wonders[6]),
  Img(39, "assets/img1.jpg", wonders[7]),
  Img(40, "assets/img2.jpg", wonders[8]),
  Img(45, "assets/img2.jpg", wonders[0]),
];

final List<WonderShort> wondershorts = [
  WonderShort(1, 215, "Ceci est la edscription d'un wondershort dans son ensemble avec bcp d'elements", "assets/videos/1.mp4", "12-02-2024", 1000, wonders[0]),
  WonderShort(2, 555, "Ceci est la edscription d'un wondershort dans son ensemble avec bcp d'elements", "assets/videos/2.mp4", "12-02-2024", 505, wonders[1]),
  WonderShort(3, 100, "Ceci est la edscription d'un wondershort dans son ensemble avec bcp d'elements", "assets/videos/3.mp4", "12-02-2024", 241, wonders[0]),
  WonderShort(4, 55, "Ceci est la edscription d'un wondershort dans son ensemble avec bcp d'elements", "assets/videos/4.mp4", "12-02-2024", 13251, wonders[3]),
];