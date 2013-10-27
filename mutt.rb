require 'formula'

class Mutt < Formula
  homepage 'http://www.mutt.org/'
  url 'ftp://ftp.mutt.org/mutt/devel/mutt-1.5.22.tar.gz'
  sha1 '728a114cb3a44df373dbf1292fc34dd8321057dc'

  head do
    url 'http://dev.mutt.org/hg/mutt#HEAD', :using => :hg

    resource 'html' do
      url 'http://dev.mutt.org/doc/manual.html', :using => :nounzip
    end

    depends_on :autoconf
    depends_on :automake
  end

  option "with-debug", "Build with debug option enabled"
  option "with-trash-patch", "Apply trash folder patch"
  option "with-slang", "Build against slang instead of ncurses"
  option "with-ignore-thread-patch", "Apply ignore-thread patch"
  option "with-pgp-verbose-mime-patch", "Apply PGP verbose mime patch"
  option "with-confirm-crypt-hook-patch", "Apply confirm crypt hook patch"
  option "with-confirm-attachment-patch", "Apply confirm attachment patch"
  option "mua", "Build without mail fetching/sending support"

  depends_on 'tokyo-cabinet'
  depends_on 's-lang' => :optional

  def patches
    urls = [
      ['with-trash-patch', 'http://patch-tracker.debian.org/patch/series/dl/mutt/1.5.21-6.4/features/trash-folder'],
      # original source for this went missing, patch sourced from Arch at
      # https://aur.archlinux.org/packages/mutt-ignore-thread/
      ['with-ignore-thread-patch', 'https://gist.github.com/mistydemeo/5522742/raw/1439cc157ab673dc8061784829eea267cd736624/ignore-thread-1.5.21.patch'],
      ['with-pgp-verbose-mime-patch', 'http://www.doorstop.net/mutt/patch-1.5.4.vk.pgp_verbose_mime'],
      # http://www.woolridge.ca/mutt/confirm-crypt-hook.html
      ['with-confirm-crypt-hook-patch', 'http://www.woolridge.ca/mutt/patches/patch-1.5.6.dw.confirm-crypt-hook.1'],
      # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=182069
      ['with-confirm-attachment-patch', 'https://gist.github.com/tlvince/5741641/raw/c926ca307dc97727c2bd88a84dcb0d7ac3bb4bf5/mutt-attach.patch'],

    ]

    p = []
    urls.each do |u|
      p << u[1] if build.include? u[0]
    end

    return p
  end

  def install
    args = ["--disable-dependency-tracking",
            "--disable-warnings",
            "--prefix=#{prefix}",
            "--enable-hcache",
            "--with-tokyocabinet",
            # This is just a trick to keep 'make install' from trying to chgrp
            # the mutt_dotlock file (which we can't do if we're running as an
            # unpriviledged user)
            "--with-homespool=.mbox"]
    args << "--with-slang" if build.with? 's-lang'

    if not build.include? 'mua'
      etc = ["--with-ssl",
             "--with-sasl",
             "--with-gss",
             "--enable-imap",
             "--enable-smtp",
             "--enable-pop"]
      args = args + etc
    end

    args << "--with-slang" if build.include? 'with-slang'

    if build.include? 'with-debug'
      args << "--enable-debug"
    else
      args << "--disable-debug"
    end

    if build.head?
      system "./prepare", *args
    else
      system "./configure", *args
    end
    system "make"
    system "make", "install"

    (share/'doc/mutt').install resource('html') if build.head?
  end
end
