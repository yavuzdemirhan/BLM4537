class ImageHelper {
  static String getImageByCategory(String category) {
    switch (category) {
      case 'Enduro':
        return "https://images.unsplash.com/photo-1591637333184-19aa84b3e01f?q=80&w=1000"; // Dağ motoru
      case 'Racing':
        return "https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?q=80&w=1000"; // Yarış motoru
      case 'Chopper':
        return "https://images.unsplash.com/photo-1558981403-c5f9899a28bc?q=80&w=1000"; // Harley tarzı
      case 'Touring':
        return "https://images.unsplash.com/photo-1609630875171-b1321377ee65?q=80&w=1000"; // Uzun yol
      default:
        return "https://images.unsplash.com/photo-1558981285-6f0c94958bb6?q=80&w=1000"; // Genel
    }
  }
}