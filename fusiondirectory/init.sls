
{% set ldap = salt['pillar.get']('ldap:config', {}) %}
# fdc = FusionDirecetoryConfig
{% set fdc = salt['pillar.get']('fusiondirectory:config', {}) %}

include:
  - openldap
  - apache

fusiondirectory:
  pkg.installed:
    - sources:
      - php-Smarty3: salt://installers/php-Smarty3-3.1.10-1.noarch.rpm
      - php-Smarty3-i18n: salt://installers/php-Smarty3-i18n-1.0-1.noarch.rpm
      - schema2ldif: salt://installers/schema2ldif-1.0-1.noarch.rpm
      - fusiondirectory: salt://installers/fusiondirectory-1.0.8.5-1.noarch.rpm
      - fusiondirectory-schema: salt://installers/fusiondirectory-schema-1.0.8.5-1.noarch.rpm
    # - pkgs:
    #   - fusiondirectory
    #   - fusiondirectory-schema
    - watch_in:
      - module: apache-reload


/etc/fusiondirectory/base_config.ldif:
  file.managed:
    - source: salt://fusiondirectory/files/base_config.ldif
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - context:
      ldap: {{ ldap }}
      fdc: {{ fdc }}
    - require:
      - pkg: fusiondirectory

/etc/fusiondirectory/fusiondirectory.conf:
  file.managed:
    - source: salt://fusiondirectory/files/fusiondirectory.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - context:
      ldap: {{ ldap }}
    - require:
      - pkg: fusiondirectory

/usr/sbin/fusiondirectory-insert-schema:
  cmd.run

/usr/sbin/fusiondirectory-setup --yes --check-directories --update-cache --update-locales:
  cmd.run

ldapadd -x -w {{ ldap['root_pwd'] }} -D "{{ ldap['root_user'] }},{{ ldap['base'] }}" -f /etc/fusiondirectory/base_config.ldif:
  cmd.run

# ldapsearch -x -W -D "{{ ldap['root_user'] }},{{ ldap['base'] }}" -b "{{ ldap['base'] }}" "(objectclass=*)"
# ldapadd -x -W -D "{{ ldap['root_user'] }},{{ ldap['base'] }}" -f /etc/fusiondirectory/base_config.ldif
