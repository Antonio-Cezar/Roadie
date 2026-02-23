import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl

# import the wifi backend we created
from wifi_manager import WifiManager


def main():
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Make sure QML import paths include PySide6's bundled modules and your project folder
    try:
        import PySide6
        pyside_qml_dir = Path(PySide6.__file__).resolve().parent / "qml"
        engine.addImportPath(str(pyside_qml_dir))
    except Exception:
        pass
    engine.addImportPath(str(Path(__file__).resolve().parent))

    # Expose WifiManager instance to QML as a context property named "wifi"
    wifi = WifiManager()
    engine.rootContext().setContextProperty("wifi", wifi)

    # Load main.qml via absolute path
    qml_path = Path(__file__).resolve().parent / "main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_path)))

    if not engine.rootObjects():
        print("Failed to load QML (check paths/imports).", file=sys.stderr)
        sys.exit(1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
