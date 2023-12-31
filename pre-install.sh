#!/bin/bash

root_partition="/dev/sda3"

user_name="zelf"
pass="1903758"

hostname="arch"

show_status() {
    echo -e "\n---- $1 ----\n"
}

mount_partitions() {
    show_status "Montando partições"
    mount "$root_partition" /mnt
}

install_base_system() {
    show_status "Instalando sistema base"
    pacstrap /mnt base linux linux-firmware
    genfstab -U /mnt >> /mnt/etc/fstab
}

configure_system() {
    show_status "Configurando sistema"
    arch-chroot /mnt /bin/bash -c "
        ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
        hwclock --systohc
        echo 'pt_BR.UTF-8 UTF-8' > /etc/locale.gen
        locale-gen
        echo 'LANG=pt_BR.UTF-8' > /etc/locale.conf
        echo '$hostname' > /etc/hostname
        echo '127.0.0.1 localhost' >> /etc/hosts
        echo '::1 localhost' >> /etc/hosts
        echo '::1 $hostname.localdomain $hostname' >> /etc/hosts
        pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd netctl
        "
}

install_grub() {
    show_status "Instalando GRUB"
    arch-chroot /mnt /bin/bash -c "
        pacman -S grub --noconfirm
        grub-install --target=i386-pc $root_partition
        grub-mkconfig -o /boot/grub/grub.cfg
        "
}

install_xfce4() {
    show_status "Instalando XFCE4"
    arch-chroot /mnt /bin/bash -c "
        pacman -S xfce4 xfce4-goodies --noconfirm
        "
}

add_user() {
    show_status "Adicionando usuário"
    arch-chroot /mnt /bin/bash -c "
        useradd -m -G wheel -s /bin/bash $user_name
        passwd $pass
        echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
        "
}

set_root_password() {
    show_status "Configurando senha de root"
    arch-chroot /mnt /bin/bash -c "passwd"
}

unmount_partitions() {
    show_status "Desmontando partições"
    umount -R /mnt
}

mount_partitions
install_base_system
configure_system
install_grub
install_xfce4
add_user
set_root_password
unmount_partitions

show_status "Instalação concluída! Reinicie o sistema para acessar o dual boot."