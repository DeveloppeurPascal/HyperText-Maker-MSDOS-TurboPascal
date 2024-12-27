program Hyper_Text_Run;
{
Auteur: Patrick Premartin
Date: 28/12/1991.
      30/12/1991.
      30/07/1992.
Langage: Turbo Pascal 6.0
But: Utilisation de l'hyper texte contenu dans le fichier .HTD pass‚ en
     paramŠtre.
}
uses
    crt,
    u_setup,
    u_htd,
    u_m_util,
    u_parametre,
    u_sgf;

const
     num_vers : string [3] = '1.1';
     dat_vers : string [10] = '07/30/1992';
     nom_fich : string [12] = 'HTPREPAT.HTD';

var
   ht : p_hyper_text;
   fich : string;
   i : word;

procedure licence;
begin
     textattr := $07;
     writeln ('Olf Software presents: Hyper Text Run '+num_vers);
     writeln ('(c) Patrick Premartin '+dat_vers);
     writeln ('This program is freeware. But you can make a donation to PREMARTIN  PATRICK,');
     writeln ('                                                         LOT. LE  SOLEIADOU,');
     writeln ('                                                           13790  ROUSSET,');
     writeln ('                                                               FRANCE');
     writeln;
     alert ('', al_wait);
end; { Licence }

begin
     fich := nom_fich;
     i := 0;
     if param_del ('/LICENCE')
     then
         licence
     else
         while (i <= paramcount) do
               begin
                    ht := new (p_hyper_text, load (fich));
                    if (ht <> nil)
                    then
                        begin
                             if (ht^.test)
                             then
                                 ht^.run
                             else
                                 if (paramcount = 0)
                                 then
                                     alert ('I need a parameter, or file '+nom_fich+'...', al_error);
                                 {endif}
                             {endif}
                             dispose (ht, done);
                        end;
                    {endif}
                    inc (i);
                    if (i <= paramcount)
                    then
                        fich := paramstr (i);
                    {endif}
               end;
         {endwhile}
     {endif}
end. { Hyper_Text_Run }
