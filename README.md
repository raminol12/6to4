# اسکریپت تانل 6to4 GRE 

این اسکریپت برای ایجاد یک تانل 6to4 GRE بین دو سرور (یکی در ایران و دیگری در خارج) استفاده می‌شود. این تانل به شما امکان می‌دهد تا ترافیک خود را از طریق سرور خارجی هدایت کنید. برای دریافت آموزش های بیشتر به کانال ما مراجعه کنید (https://t.me/UnblockedX)

## پیش‌نیازها

* دو سرور لینوکس (یکی در ایران و دیگری در خارج از ایران)
* دسترسی root یا sudo به هر دو سرور
* آی‌پی عمومی معتبر برای هر دو سرور

## نحوه استفاده

1.  اسکریپت `tunnel_script.sh` را در هر دو سرور دانلود کنید. می‌توانید از دستور زیر برای دانلود و اجرای مستقیم اسکریپت استفاده کنید:
    ```bash
    bash <(curl -sL https://raw.githubusercontent.com/raminol12/6to4/main/tunnel_script.sh)
    ```
    یا به صورت دستی:
    *   اسکریپت را دانلود کنید.
    *   به اسکریپت مجوز اجرا بدهید:
        ```bash
        chmod +x tunnel_script.sh
        ```
    *   اسکریپت را در هر سرور اجرا کنید:
        ```bash
        ./tunnel_script.sh
        ```

2.  هنگام اجرای اسکریپت، از شما سوالاتی پرسیده می‌شود:
    *   **Choose which side you are configuring (1/2):** انتخاب کنید که در حال پیکربندی سرور ایران (1) هستید یا سرور خارج (2).
    *   **Enter Foreign Server Public IP:** آی‌پی عمومی سرور خارجی را وارد کنید.
    *   **Enter Iran Server Public IP:** آی‌پی عمومی سرور ایران را وارد کنید.
    *   **Enter desired SSH port to forward (only on Iran side):** (فقط برای سرور ایران) پورت SSH مورد نظر برای فوروارد را وارد کنید. این پورت برای دسترسی به سرور خارجی از طریق تانل استفاده خواهد شد.

### پیکربندی سمت ایران

هنگامی که گزینه `1` را برای سرور ایران انتخاب می‌کنید، اسکریپت تنظیمات زیر را انجام می‌دهد:

*   ایجاد یک تانل SIT به نام `6to4_iran` بین سرور ایران و سرور خارج.
*   اختصاص آدرس IPv6 محلی (`2002:a00:100::1/64`) به اینترفیس `6to4_iran`.
*   فعال‌سازی اینترفیس `6to4_iran`.
*   ایجاد یک تانل GRE6 به نام `GRE6Tun_iran` با استفاده از آدرس‌های IPv6 محلی.
*   اختصاص آدرس IP (`10.10.187.1/30`) به اینترفیس `GRE6Tun_iran`.
*   فعال‌سازی اینترفیس `GRE6Tun_iran`.
*   فعال‌سازی `ip_forward`.
*   تنظیم قوانین `iptables` برای NAT کردن ترافیک SSH به سمت سرور خارجی و MASQUERADE کردن سایر ترافیک‌ها.

### پیکربندی سمت خارج

هنگامی که گزینه `2` را برای سرور خارج انتخاب می‌کنید، اسکریپت تنظیمات زیر را انجام می‌دهد:

*   ایجاد یک تانل SIT به نام `6to4_Forign` بین سرور خارج و سرور ایران.
*   اختصاص آدرس IPv6 محلی (`2002:a00:100::2/64`) به اینترفیس `6to4_Forign`.
*   فعال‌سازی اینترفیس `6to4_Forign`.
*   ایجاد یک تانل GRE6 به نام `GRE6Tun_Forign` با استفاده از آدرس‌های IPv6 محلی.
*   اختصاص آدرس IP (`10.10.187.2/30`) به اینترفیس `GRE6Tun_Forign`.
*   فعال‌سازی اینترفیس `GRE6Tun_Forign`.

## نکات مهم

*   این اسکریپت تنظیمات را در فایل `/etc/rc.local` ذخیره می‌کند تا پس از راه‌اندازی مجدد سرور، تانل به صورت خودکار برقرار شود. <mcreference link="https://github.com/raminol12/6to4" index="0">0</mcreference>
*   پس از اجرای اسکریپت، ممکن است نیاز به راه‌اندازی مجدد سرور یا اجرای دستی `/etc/rc.local` داشته باشید. <mcreference link="https://github.com/raminol12/6to4" index="0">0</mcreference>
*   مطمئن شوید که فایروال سرورها اجازه عبور ترافیک مورد نیاز برای تانل‌ها (SIT و GRE) را می‌دهد.
*   سرورها باید تمیز باشند و آی‌پی لوکال در سرور شما مسدود نباشد. <mcreference link="https://github.com/raminol12/6to4" index="0">0</mcreference>
*   داشتن آی‌پی ورژن 6 اصلاً مهم نیست، اسکریپت خودش آن را می‌سازد. <mcreference link="https://github.com/raminol12/6to4" index="0">0</mcreference>
*   اگر سرور ریستارت شود، تانل از کار می‌افتد و اسکریپت را باید مجدداً اجرا کنید (مگر اینکه `rc.local` به درستی تنظیم شده باشد). <mcreference link="https://github.com/raminol12/6to4" index="0">0</mcreference>
*   این تانل تمامی پورت‌ها را بصورت یکجا تانل می‌کند و نیازی به وارد کردن پورت خاصی نیست (به جز پورت SSH برای فورواردینگ اولیه در سمت ایران). <mcreference link="https://github.com/raminol12/6to4" index="0">0</mcreference>


## حمایت مالی

اگر این پروژه برای شما مفید بوده است، می‌توانید از طریق آدرس‌های زیر از ما حمایت کنید:

*   تتر (TRC20): `TKqV6MWsdcrGPXVK5DL2eTYz339Psp3Zwp`
*   بیتکوین (BSC BEP20): `0x4f19f5071bc49833c4cd9c1e646c03db195c9ffe`
