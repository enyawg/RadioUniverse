/// Model for audio advertisements
class AudioAd {
  final String id;
  final String title;
  final String audioUrl;
  final AdType type;
  final int durationSeconds;
  final String? clickUrl; // Optional URL to open if user taps during ad
  
  const AudioAd({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.type,
    required this.durationSeconds,
    this.clickUrl,
  });
}

enum AdType {
  houseAd,     // Your own ads (upgrade to pro)
  sponsorAd,   // Paid sponsor ads
  programmatic // Future: programmatic ads from networks
}

// Pre-defined ads
class AudioAds {
  static final AudioAd upgradeToProAd = AudioAd(
    id: 'upgrade_pro_1',
    title: 'Upgrade to Radio Universe Pro',
    audioUrl: 'assets/audio/upgrade_to_pro.mp3',
    type: AdType.houseAd,
    durationSeconds: 10,
  );
  
  // Example sponsor ads (you'd add real ones)
  static final List<AudioAd> sponsorAds = [
    AudioAd(
      id: 'spotify_1',
      title: 'Spotify Premium',
      audioUrl: 'https://example.com/spotify_ad.mp3',
      type: AdType.sponsorAd,
      durationSeconds: 15,
      clickUrl: 'https://spotify.com/premium',
    ),
    AudioAd(
      id: 'audible_1', 
      title: 'Try Audible Free',
      audioUrl: 'https://example.com/audible_ad.mp3',
      type: AdType.sponsorAd,
      durationSeconds: 12,
      clickUrl: 'https://audible.com/trial',
    ),
  ];
}