# Участие в проекте

Баги и идеи: [Issues](https://github.com/playsin333/playsin-boost/issues/new/choose). Обсуждение: [Discord](https://discord.gg/brMD3VYUAu).

Укажи версию BOOST, сборку Windows, оборудование по теме, шаги, ожидаемый и фактический результат. Убирай личные данные из логов. Уязвимости сообщай по [SECURITY.md](SECURITY.md).

Главный исходник — гибридный `PLAYSIN BOOST 3.0.bat`. Сохраняй UTF-8 и CRLF для BAT. Не добавляй резервные данные, пользовательские отчёты, пароли и токены. Изменение системного блока должно объяснять последствия и учитывать сохранение исходного значения, ошибку и откат.

Проверки запускаются в отдельных процессах, с временными папками и имитацией системных команд:

```powershell
pwsh -NoProfile -File tests/Run-Tests.ps1
pwsh -NoProfile -File tests/AfterReport.Tests.ps1
pwsh -NoProfile -File tests/Update.Tests.ps1
pwsh -NoProfile -File tests/Tuning.Tests.ps1
```

Run-Tests подключает Setup, Startup, Regression, Product, Audit и Checker. Для совместимости повтори набор в Windows PowerShell 5.1. Применение оптимизации на рабочей Windows для проверки упаковки не требуется.

[Сборка](docs/UPDATE-CHANNEL.md). Любое изменение пользовательского комплекта требует новой версии и пересборки сумм. Общая лицензия авторского кода пока не выбрана.
