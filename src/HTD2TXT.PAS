program Convert_HTD_to_TXT;
{
Auteur: Patrick Premartin
Date: 10/01/1993.
Langage: Turbo Pascal 6.0
But: Conversion des fichiers d'Hyper-Texte Maker en fichiers texte ASCII afin
     de pouvoir les imprimer ou en faciliter les modifications.
}
{$m 32768, 0, 655360}
uses
    olf_software,
    dos,
    crt,
    u_date,
    u_time,
    u_htd,
    u_htp,
    u_m_util,
    u_sgf,
    u_parametre;

const
     num_vers : string [3] = '1.0';
     dat_vers : string [10] = '01/10/1993';

type
    tf2 = text;

var
   fich2 : tf2;
   fich_type : searchrec;
   nom,
   nom1,
   nom2 : string;
   dir1,
   dir2 : dirstr;
   name : namestr;
   ext : extstr;
   ht : p_hyper_text;

procedure modification;
var
   ch : string;
   pos_x,
   i, j, k, l : word;
   bt : p_bouton;
begin
  writeln (fich2, '.;', nom1, '     ', get_date_chaine, '     ', get_time_chaine);
  writeln (fich2, '.;');
  writeln (fich2, '.; HTD2TXT '+num_vers+' used to generate this file.');
  writeln (fich2, '.; (c) Patrick Pr‚martin '+dat_vers);
  writeln (fich2, '.; (c) Olf Software 1993');
  writeln (fich2, '.;');
  writeln (fich2, '.START ', ht^.ht [ht^.debut]^.txt^.fich_name);
  write ('     ');
  pos_x := wherex;
  for i := 1 to max_ecran do
    if (ht^.ht [i] <> nil)
    then
      begin
        gotoxy (pos_x, wherey);
        write (i);
        writeln (fich2, '.;');
        writeln (fich2, '.TOPIC ', ht^.ht [i]^.txt^.fich_name);
        writeln (fich2, '.COLOR ', ht^.ht [i]^.couleur);
        l := 0;
        for j := 1 to max_lig do
          begin
            ch := '';
            for k := 1 to max_col do
              begin
                if (l = 0)
                then
                  begin
                    bt := ht^.ht [i]^.liste_bouton;
                    while ((bt <> nil) and ((bt^.y < j) or (bt^.x < k))) do
                      bt := bt^.next;
                    {endwhile}
                    if ((bt <> nil) and (bt^.x = k) and (bt^.y = j))
                    then
                      begin
                        l := bt^.l;
                        ch := ch + '{';
                        if (bt^.effet.go_to = 0)
                        then
                          ch := ch + bt^.go_to_name+'='
                        else
                          ch := ch + ht^.ht [bt^.effet.go_to]^.txt^.fich_name+'=';
                        {endif}
                      end;
                    {endif}
                  end;
                {endif}
                if (ht^.ht [i]^.txt^.ecran^.tab [j, k] = '{')
                then
                  ch := ch + '{{'
                else
                  if ((l > 0) and (ht^.ht [i]^.txt^.ecran^.tab [j, k] = '}'))
                  then
                    ch := ch + '}}'
                  else
                    ch := ch+ht^.ht [i]^.txt^.ecran^.tab [j, k];
                  {endif}
                {endif}
                case l of
                  0 :;
                  1 :
                    begin
                      l := 0;
                      ch := ch + '}';
                    end;
                else
                  dec (l);
                end;
              end;
            {endfor}
            while (ch [length (ch)] = ' ') do
              dec (ch [0]);
            {endwhile}
            writeln (fich2, ch);
          end;
        {endfor}
      {endif}
    end;
  {endfor}
end; { Modification }

begin
     init_licence ('MKHT');
     init_olf_message (mess_shareware);
     init_ligne_olf_software ('Convert .HTD to .TXT '+num_vers, '(c) Patrick Premartin '+dat_vers);
     if ((param_del ('/H')) or (param_del ('/?')))
     then
         begin
              writeln ('Syntax:');
              writeln ('       HTD2TXT [file_name[.HTD]] [/H|/?]');
              writeln;
              writeln ('Convert File_Name.HTD in File_Name.TXT');
              writeln ('* and ? are accepted...');
              writeln;
              writeln ('HTD Files are Hyper Text Maker (Olf Software program) files.');
              writeln ('TXT are ASCII files');
         end
     else
         if (paramcount > 0)
         then
             begin
                  fsplit (fexpand (paramstr (1)), dir1, name, ext);
                  nom := dir1+name+'.HTD';
                  findfirst (nom, archive, fich_type);
                  while (doserror = 0) do
                        begin
                             fsplit (fexpand (fich_type.name), dir2, name, ext);
                             nom1 := dir1+name+'.HTD';
                             nom2 := dir1+name+'.TXT';
                             write ('Converting: '+nom1);
                             ht := new (p_hyper_text, load (nom1));
                             if (ht = nil)
                             then
                                 alert ('Can not access '+nom1+' !', al_error)
                             else
                                 begin
                                      cree_bak (nom2);
                                      assign (fich2, nom2);
                                      {$i-}
                                      rewrite (fich2);
                                      {$i+}
                                      if (ioresult <> 0)
                                      then
                                          alert ('Can not access '+nom2+' !', al_error)
                                      else
                                          begin
                                               modification;
                                               close (fich2);
                                          end;
                                      {endif}
                                      dispose (ht, done);
                                 end;
                             {endif}
                             writeln;
                             findnext (fich_type);
                        end;
                  {endwhile}
             end;
         {endif}
     {endif}
end.

