class AppImages {
  static const String basePathImage = "assets/images/";

  static const String backgroundRolle = "${basePathImage}background1.png";
  static const String backgroundMain = "${basePathImage}backgroung_main.png";
  static const String perosnalImg = "${basePathImage}women.webp";

  // Offer images
  static const String testLizer = "${basePathImage}lizar.jpg";
  static const String potoks = "${basePathImage}potoks.jpg";
  static const String testCare = "${basePathImage}scancare.jpg";
  static const String brokenHeard = "${basePathImage}broken-heart.png";

  // Category icons (home grid)
  static const String hairIcon = "${basePathImage}hair.png";
  static const String nailIcon = "${basePathImage}nails1.png";
  static const String skinCareIcon = "${basePathImage}skincare.png";
  static const String lizerIcon = "${basePathImage}laser_removal.png";
  static const String spaIcon = "${basePathImage}spa.png";
  static const String makeUpIcon = "${basePathImage}makeup.png";
  static const String medicalIcon = "${basePathImage}medicalconsult.png";
  static const String productIcon = "${basePathImage}products.png";

  // Category background images (services screen header)
  static const String hairSection = "${basePathImage}hair_section.webp";
  static const String nailsSection = "${basePathImage}Nails_1.jpg";
  static const String skinCareSection = "${basePathImage}potoks.jpg";
  static const String laserSection = "${basePathImage}lizar.jpg";
  static const String spaSection = "${basePathImage}potoks.jpg";
  static const String makeupSection = "${basePathImage}scancare.jpg";
  static const String medicalSection = "${basePathImage}lizar.jpg";
  static const String productsSection = "${basePathImage}hair_section.webp";

  static String categoryBg(String category) {
    switch (category.toLowerCase()) {
      case 'hair': return hairSection;
      case 'nails': return nailsSection;
      case 'skincare': return skinCareSection;
      case 'laser': return laserSection;
      case 'spa': return spaSection;
      case 'makeup': return makeupSection;
      case 'medical': return medicalSection;
      case 'products': return productsSection;
      default: return hairSection;
    }
  }
}
