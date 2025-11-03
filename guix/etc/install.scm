(use-modules (gnu))
(use-service-modules networking ssh)
(use-package-modules screen ssh)

(operating-system
  (host-name "arrowhead")
  (timezone "Asia/Tokyo")
  (locale "en_US.utf8")

  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (targets '("/dev/sda"))))
  (kernel-arguments (list "console=ttyS0,115200"))
  (file-systems (cons (file-system
                        (device (file-system-label "root"))
                        (mount-point "/")
                        (type "ext4"))
                      %base-file-systems))

  (users (cons (user-account
                (name "clest")
                (group "users")

                (supplementary-groups '("wheel")))
               %base-user-accounts))

  (packages (cons screen %base-packages))

  (initrd-modules (append (list "virtio_scsi")
                          %base-initrd-modules))

  (services (append (list (service openssh-service-type
                                   (openssh-configuration
                                    (openssh openssh-sans-x)
                                    (port-number 2222))))
                    %base-services)))
