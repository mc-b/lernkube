Konfigurationsdateien
---------------------

Plathalter für Dateien welche beim Erstellen der VM zusätzliche Installationen oder weitere Konfigurationen anfügen.

Unterstützt werden:
* `wg0.conf`: WireGuard wird installiert und gestartet
* `authorized_keys`: wird an `/home/vagrant/.ssh/authorized_keys` angefügt. 