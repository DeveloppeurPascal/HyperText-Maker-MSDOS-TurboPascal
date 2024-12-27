program Convert_TXT_to_HTD;
{
Auteur: Patrick Premartin
Date: 10/01/1993.
Langage: Turbo Pascal 6.0
But: G‚n‚ration d'hyper-textes … partir d'un fichier ASCII au mˆme format que
     les textes d'aide de Turbo Vision.
}
{$m 32768, 0, 655360}
uses
    olf_software,
    dos,
    crt,
    u_sgf,
    u_htd,
    u_htp,
    u_date,
    u_time,
    u_m_util,
    u_parametre,
    u_ger_chaine;

const
     num_vers : string [3] = '1.0';
     dat_vers : string [10] = '01/10/1993';

type
    tf1 = text;

var
   fich1 : tf1;
   fich_type : searchrec;
   nom,
   nom1,
   nom2 : string;
   dir1,
   dir2 : dirstr;
   name : namestr;
   ext : extstr;
   ht : p_hyper_text;

procedure change_compteur (var cpt : t_str8);
var
   i : byte;
begin
  i := 8;
  repeat
    if (cpt [i] = 'Z')
    then
      begin
        cpt [i] := 'A';
        dec (i);
      end
    else
      begin
        inc (cpt [i]);
        i := 1;
      end;
    {endif}
  until (i = 1);
end; { cpt }

procedure transfert_bouton (n1, n2 : word; var j : word);
var
   bt1, bt2, bt3 : p_bouton;
begin
  bt3 := ht^.ht [n1]^.liste_bouton;
  while ((bt3 <> nil) and (bt3^.y < pred (max_lig))) do
    bt3 := bt3^.next;
  {endwhile}
  while ((bt3 <> nil) and (bt3^.y <> max_lig) and (bt3^.x+bt3^.l <= succ (max_col))) do
    bt3 := bt3^.next;
  {endwhile}
  if (bt3 <> nil)
  then
    if (bt3^.y < max_lig)
    then
      begin
        bt1 := new (p_bouton, init);
        bt1^.x := 1;
        bt1^.y := 2;
        bt1^.l := pred ((bt3^.x+bt3^.l)-max_col);
        bt1^.effet := bt3^.effet;
        bt1^.go_to_name := bt3^.go_to_name;
        bt3^.l := bt3^.l -bt1^.l;
        bt3 := bt3^.next;
        j := 3;
      end;
    {endif}
    if (bt3 <> nil)
    then
      begin
        bt2 := ht^.ht [n2]^.liste_bouton;
        while (bt2^.next <> nil) do
          bt2 := bt2^.next;
        {endwhile}
        bt2^.next := bt3;
        bt2 := bt3;
        while (bt2 <> nil) do
          begin
            bt2^.y := 2;
            bt2 := bt2^.next;
          end;
        {endwhile}
        bt1 := ht^.ht [n1]^.liste_bouton;
        if (bt1 = bt3)
        then
          ht^.ht [n1]^.liste_bouton := nil
        else
          begin
            while (bt1^.next <> bt3) do
              bt1 := bt1^.next;
            {endwhile}
            bt1^.next := nil;
          end;
        {endif}
        j := 3;
      end;
    {endif}
  {endif}
end; { transfert_bouton }

procedure modification;
var
   x,
   l,                { Longueur du bouton actuel }
   i,                { Num‚ro de la page en cours de cr‚ation }
   j,                { Num‚ro de la ligne courante }
   k : word;         { Num‚ro de la colonne courante }
   coul_dflt : byte; { Couleur des pages par d‚faut }
   bt2,
   bt : p_bouton;    { Bouton en cours de cr‚ation }
   ch,               { Chaine lue }
   wrk1,
   wrk : string;     { Chaine de travail, MAJ, Compression... }
   cpt : t_str8;     { Compteur pour pages trop longues }
   pos_x : word;     { Position du curseur sur ligne en cours }
   tst_pag : boolean;{ A vrai si on a d‚j… cr‚‚ une page }
   pag_nam :t_str8;

   procedure nouvelle_page;
   var
      c : byte;
      ch : string;
      bt2, bt3 : p_bouton;
      k : word;
   begin
     { On commence par finir la page en cours }
     if (tst_pag)
     then
       if (j < max_lig)
       then
         begin
           while (j <= max_lig) do
             begin
               for k := 1 to max_col do
                 ht^.ht [i]^.txt^.ecran^.tab [j, k] := ' ';
               {endfor}
               inc (j);
             end;
           {endwhile}
           if (l > 0)
           then
             bt^.l := l;
           {endif}
           l := 0;
         end
       else
         begin
           ch := '';
           for k := 1 to max_col do
             begin
               ch := ch + ht^.ht [i]^.txt^.ecran^.tab [max_lig, k];
               ht^.ht [i]^.txt^.ecran^.tab [max_lig, k] := ' ';
             end;
           {endfor}
           if (l > 0)
           then
             if (bt^.y = max_lig)
             then
               begin
                 bt3 := ht^.ht [i]^.liste_bouton;
                 if (bt3 = bt)
                 then
                   ht^.ht [i]^.liste_bouton := bt^.next
                 else
                   begin
                     while (bt3^.next = bt) do
                       bt3 := bt3^.next;
                     {endwhile}
                     bt3^.next := bt^.next;
                   end;
                 {endif}
                 bt2 := bt;
                 bt2^.y := 2;
               end
             else
               begin
                 bt^.l := succ (max_col-bt^.x);
                 l := l - bt^.l;
                 bt2 := new (p_bouton, init);
                 bt2^.x := 1;
                 bt2^.y := 2;
                 bt2^.effet.go_to := bt^.effet.go_to;
                 bt2^.go_to_name := bt^.go_to_name;
               end;
             {endif}
           {endif}
         end;
       {endif}
     {endif}
     c := ht^.ht [i]^.couleur;
     ht^.ht [i]^.txt^.ecran^.tab [max_lig, 1] := '.';
     ht^.ht [i]^.txt^.ecran^.tab [max_lig, 2] := '.';
     ht^.ht [i]^.txt^.ecran^.tab [max_lig, 3] := '.';
     if (i = max_ecran)
     then
       begin
         writeln;
         writeln;
         writeln ('Hyper-Text full of page...');
         halt (0);
       end;
     {endif}
     inc (i);
     ht^.ht [i] := new (p_ecran, init);
     tst_pag := (ht^.ht [i] <> nil);
     if (tst_pag)
     then
       begin
         ht^.ht [i]^.txt := new (p_txt, init);
         tst_pag := (ht^.ht [i]^.txt <> nil);
         if (tst_pag)
         then
           begin
             new (ht^.ht [i]^.txt^.ecran);
             tst_pag := (ht^.ht [i]^.txt^.ecran <> nil);
             ht^.ht [i]^.couleur := c;
             ht^.ht [i]^.txt^.fich_name := cpt;
             for k := 1 to max_col do
               ht^.ht [i]^.txt^.ecran^.tab [1, k] := ' ';
             {endfor}
             ht^.ht [i]^.txt^.ecran^.tab [1, 1] := '.';
             ht^.ht [i]^.txt^.ecran^.tab [1, 2] := '.';
             ht^.ht [i]^.txt^.ecran^.tab [1, 3] := '.';
             bt := new (p_bouton, init);
             bt^.x := 1;
             bt^.y := 1;
             bt^.l := 3;
             bt^.effet.go_to := 0;
             bt^.go_to_name := pag_nam;
             ht^.ht [i]^.liste_bouton := bt;
             pag_nam := ht^.ht [i]^.txt^.fich_name;
             if (l = 0)
             then
               j := 2
             else
               j := 3;
             {endif}
             transfert_bouton (pred (i), i, j);
             bt := new (p_bouton, init);
             bt^.x := 1;
             bt^.y := max_lig;
             bt^.l := 3;
             bt^.effet.go_to := 0;
             bt^.go_to_name := cpt;
             if (ht^.ht [i-1]^.liste_bouton = nil)
             then
               ht^.ht [i-1]^.liste_bouton := bt
             else
               begin
                 bt3 := ht^.ht [i-1]^.liste_bouton;
                 while (bt3^.next <> nil) do
                   bt3 := bt3^.next;
                 {endwhile}
                 bt3^.next := bt;
               end;
             {endif}
             bt := bt2;
             if (l > 0)
             then
               ht^.ht [i]^.liste_bouton^.next := bt;
             {endif}
             for k := 1 to max_col do
               ht^.ht [i]^.txt^.ecran^.tab [2, k] := ch [k];
             {endfor}
             k := 1;
             change_compteur (cpt);
           end
         else
           begin
             dispose (ht^.ht [i], done);
             ht^.ht [i] := nil;
           end;
         {endif}
       end;
     {endif}
   end; { nouvelle_page }

begin
  pos_x := wherex+5;
  tst_pag := false;
  i := 0;
  coul_dflt := 1;
  cpt := '_AAAAAAA';
  while not eof (fich1) do
    begin
      readln (fich1, ch);
      wrk := ch;
      while ((wrk [0] > #0) and (wrk [1] = ' ')) do
        delete (wrk, 1, 1);
      {endwhile}
      if ((wrk [0] > #0) and (wrk [1] = '.'))
      then
        begin
          wrk := set_maj_chaine (wrk);
          repeat
            x := pos (' ', wrk);
            if (x > 0)
            then
              delete (wrk, x, 1);
            {endif}
          until (x = 0);
          wrk1 := copy (wrk, 1, 6);
          if (wrk1 [2] = ';')
          then
            { Ne rien faire, c'est un commentaire }
          else
            if (wrk1 = '.COLOR')
            then
              case tst_pag of
                true : ht^.ht [i]^.couleur := ord (wrk [7])-ord ('0');
                false : coul_dflt := ord (wrk [7])-ord ('0');
              end
            else
              if (wrk1 = '.START')
              then
                label_ht := copy (wrk, 7, 8)
              else
                if (wrk1 = '.TOPIC')
                then
                  begin
                    { On commence par finir la page en cours }
                    if (tst_pag)
                    then
                      begin
                        inc (j);
                        while (j <= max_lig) do
                          begin
                            for k := 1 to max_col do
                              ht^.ht [i]^.txt^.ecran^.tab [j, k] := ' ';
                            {endfor}
                            inc (j);
                          end;
                        {endwhile}
                        if (l > 0)
                        then
                          bt^.l := l;
                        {endif}
                      end;
                    {endif}
                    if (i = max_ecran)
                    then
                      begin
                        writeln;
                        writeln;
                        writeln ('Hyper-Text full of page...');
                        halt (0);
                      end;
                    {endif}
                    l := 0;
                    j := 0;
                    k := 1;
                    inc (i);
                    gotoxy (pos_x, wherey);
                    write (i);
                    ht^.ht [i] := new (p_ecran, init);
                    tst_pag := (ht^.ht [i] <> nil);
                    if (tst_pag)
                    then
                      begin
                        ht^.ht [i]^.txt := new (p_txt, init);
                        tst_pag := (ht^.ht [i]^.txt <> nil);
                        if (tst_pag)
                        then
                          begin
                            new (ht^.ht [i]^.txt^.ecran);
                            tst_pag := (ht^.ht [i]^.txt^.ecran <> nil);
                            ht^.ht [i]^.couleur := coul_dflt;
                            ht^.ht [i]^.txt^.fich_name := copy (wrk, 7, 8);
                            pag_nam := ht^.ht [i]^.txt^.fich_name;
                          end
                        else
                          begin
                            dispose (ht^.ht [i], done);
                            ht^.ht [i] := nil;
                          end;
                        {endif}
                      end;
                    {endif}
                  end;
                {endif}
              {endif}
            {endif}
          {endif}
        end
      else
        if (tst_pag)
        then
          repeat
            if (j < max_lig)
            then
              inc (j)
            else
              nouvelle_page;
            {endif}
            k := 1;
            x := 1;
            while ((k <= max_col) and (k <= x) and (x <= length (ch))) do
              if ((l = 0) and (ch [x] = '{'))
              then
                if ((succ (x) <= length (ch)) and (ch [succ (x)] = '{'))
                then
                  begin
                    ht^.ht [i]^.txt^.ecran^.tab [j, k] := '{';
                    inc (x, 2);
                    inc (k);
                  end
                else
                  begin
                    bt := new (p_bouton, init);
                    bt^.x := k;
                    bt^.y := j;
                    bt^.effet.go_to := 0;
                    bt^.go_to_name := '';
                    inc (x);
                    while ((x < length (ch)) and (ch [x] <> '=')) do
                      begin
                        bt^.go_to_name := bt^.go_to_name+upcase (ch [x]);
                        inc (x);
                      end;
                    {endwhile}
                    if (ht^.ht [i]^.liste_bouton = nil)
                    then
                      ht^.ht [i]^.liste_bouton := bt
                    else
                      begin
                        bt2 := ht^.ht [i]^.liste_bouton;
                        while (bt2^.next <> nil) do
                          bt2 := bt2^.next;
                        {endwhile}
                        bt2^.next := bt;
                      end;
                    {endif}
                    inc (x);
                    l := 1;
                  end
                {endif}
              else
                if ((l > 0) and (ch [x] = '}'))
                then
                  if ((succ (x) <= length (ch)) and (ch [succ (x)] = '}'))
                  then
                    begin
                      ht^.ht [i]^.txt^.ecran^.tab [j, k] := '}';
                      inc (x, 2);
                      inc (k);
                      inc (l);
                    end
                  else
                    begin
                      bt^.l := l;
                      l := 0;
                      inc (x);
                    end
                  {endif}
                else
                  begin
                    ht^.ht [i]^.txt^.ecran^.tab [j, k] := ch [x];
                    inc (k);
                    inc (x);
                    if (l > 0)
                    then
                      inc (l);
                    {endif}
                  end;
              {endif}
            {endwhile}
            while (k <= max_col) do
              begin
                ht^.ht [i]^.txt^.ecran^.tab [j, k] := ' ';
                inc (k);
                if (l > 0)
                then
                  inc (l);
                {endif}
              end;
            {endwhile}
            delete (ch, 1, pred (x));
          until (ch [0] = #0);
        {endif}
      {endif}
    end;
  {endwhile}
  { On fini la page en cours }
  if (tst_pag)
  then
    begin
      inc (j);
      while (j <= max_lig) do
        begin
          for k := 1 to max_col do
            ht^.ht [i]^.txt^.ecran^.tab [j, k] := ' ';
          {endfor}
          inc (j);
        end;
      {endwhile}
      if (l > 0)
      then
        bt^.l := l;
      {endif}
    end;
  {endif}
  ht^.debut := ht^.rech_num_name;
  if (not ht^.test)
  then
    alert ('This Hyper-Text will not run...', al_error);
  {endif}
end; { Modification }

begin
     init_licence ('MKHT');
     init_olf_message (mess_shareware);
     init_ligne_olf_software ('Convert .TXT to .HTD '+num_vers, '(c) Patrick Premartin '+dat_vers);
     if ((param_del ('/H')) or (param_del ('/?')))
     then
         begin
              writeln ('Syntax:');
              writeln ('       TXT2HTD [file_name[.TXT]] [/H|/?]');
              writeln;
              writeln ('Convert File_Name.TXT in File_Name.HTD');
              writeln ('* and ? are accepted...');
              writeln;
              writeln ('TXT are ASCII files');
              writeln ('HTD Files are Hyper Text Maker (Olf Software program) files.');
         end
     else
         if (paramcount > 0)
         then
             begin
                  fsplit (fexpand (paramstr (1)), dir1, name, ext);
                  nom := dir1+name+'.TXT';
                  findfirst (nom, archive, fich_type);
                  while (doserror = 0) do
                        begin
                             fsplit (fexpand (fich_type.name), dir2, name, ext);
                             nom1 := dir1+name+'.TXT';
                             nom2 := dir1+name+'.HTD';
                             write ('Converting: '+nom1);
                             assign (fich1, nom1);
                             {$i-}
                             reset (fich1);
                             {$i+}
                             if (ioresult <> 0)
                             then
                                 alert ('Can not access '+nom1+' !', al_error)
                             else
                                 begin
                                      cree_bak (nom2);
                                      ht := new (p_hyper_text, init);
                                      if (ht = nil)
                                      then
                                          alert ('Can not create '+nom2+' !', al_error)
                                      else
                                          begin
                                               modification;
                                               ht^.save (nom2);
                                               dispose (ht, done);
                                          end;
                                      {endif}
                                      close (fich1);
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

