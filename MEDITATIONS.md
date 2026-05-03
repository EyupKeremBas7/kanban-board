### emulator -avd FakeTrello_API36 -gpu host -no-snapshot-save -qemu -m 2048

```
Sen bu Kanban Board mobil (Flutter) projesinde çalışan kıdemli bir yazılım geliştirici ajansın. Projede katı bir iş akışımız var. Lütfen aşağıdaki adımları sırasıyla, eksiksiz bir şekilde uygula:

1. BAĞLAMI ANLAMA (CONTEXT):
- İlk olarak `mobile/SON_DEGISIKLIKLER.md` dosyasını oku ve en son nerede kalındığını, sıradaki adımın ne olduğunu anla.
- Gerekirse güncel durumu kavramak için `git log --oneline` komutuyla git geçmişine ve kod tabanına (codebase) hızlıca göz at.
- Ardından `mobile/EKSIK_FEATURELAR.md` dosyasını incele ve proje önceliklerine göre bir sonraki geliştirilecek feature'a (özelliğe) karar ver.

2. GELİŞTİRME (DEVELOPMENT):
- Geliştireceğin feature'ı KESİNLİKLE `mobile/FLUTTER_KURALLARI.md` belgesindeki mimari (Feature-Based MVVM) ve UI kurallarına harfiyen uyarak kodla.

3. TEST VE ANALİZ (VERIFICATION):
- Kodlamayı bitirdiğinde mutlaka `flutter analyze` komutunu çalıştır. 
- Eğer herhangi bir uyarı veya hata (info dahil) çıkarsa, sıfır hata olana kadar bunları düzelt.

4. ONAY (APPROVAL):
- İşlemler bittiğinde bana "Analiz temiz, kodlar hazır. Commit atmam için onay veriyor musun?" diye sor.
- BEN ONAY VERMEDEN asla git commit işlemi yapma.

5. COMMIT VE HANDOFF:
- Ben onay verdikten sonra `git add .` ve uygun, açıklayıcı bir commit mesajıyla `git commit` işlemini yap.
- Son olarak görevini başarıyla tamamladığına dair `mobile/SON_DEGISIKLIKLER.md` ve `mobile/EKSIK_FEATURELAR.md` dosyalarını güncelle ki senden sonra gelecek olan ajan işe nereden devam edeceğini bilsin.

Şimdi lütfen `SON_DEGISIKLIKLER.md` dosyasını okuyarak işe başla ve bana ne yapacağını kısaca özetle.
```