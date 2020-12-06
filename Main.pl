#!/usr/bin/perl
use strict;
use warnings;
use Text::Ngrams;

################################################################################
# Permet de récupérer l'ensemble des fichiers dans le répertoire choisi
################################################################################
sub GetFilesList {
        my $Path = $_[0];
        my $FileFound;
        my @FilesList=();

        # Lecture de la liste des fichiers
        opendir (my $FhRep, $Path)
                or die "Impossible d'ouvrir le repertoire $Path\n";
        my @Contenu = grep { !/^\.\.?$/ } readdir($FhRep);
        closedir ($FhRep);

        foreach my $FileFound (@Contenu) {
                # Traitement des fichiers
                if ( -f "$Path/$FileFound") {
                        push ( @FilesList, "$Path/$FileFound" );
                }
                # Traitement des repertoires
                elsif ( -d "$Path/$FileFound") {
                        # Boucle pour lancer la recherche en mode recursif
                        push (@FilesList, GetFilesList("$Path/$FileFound") );
                }

        }
        return @FilesList;
}

#On va créer un array contenant tous les fichiers texte
my @Files = GetFilesList ("12_TEST_JPCO/");
my @tmpFile ;
my $ng = Text::Ngrams->new(type => 'word') ;


################################################################################
# Permet de mettre toute la ligne en minuscule
################################################################################
sub parseLigne {
	return lc($_[0]);
}

################################################################################
# Permet de parser le fichier et de récuperer uniquement ce dont on à besoin
################################################################################
sub recupererLigneAvecRegex {
    my @args = @_ ;
    my @newFile = {} ;
    #Pour chaque ligne dans le fichier que l'on fait
    foreach my $myLigne (@args) {
        #On va selectionner les lignes que l'on ne met pas dedans le nouveau fichier
        if($myLigne =~ m/(^(TYPE|DOI|JOURNAL|DATE|AUTHOR|ADDRESS|ACRONYMS|KEYWORDS).*)/) {
            next ;
        }

        $myLigne =~ s/(\d+)//g ;
        #Nous allons supprimer les lignes que nous ne voulons pas
        if(($myLigne =~ s/(?=< tex-math >)(.*\n?)(< \/tex-math >)/ /) || ($myLigne =~ s/(?=<mml:math )(.*\n?)(<\/math>)/ /)) {
            if($myLigne =~ s/(?=<mml:math)(.*\n?)(<\/math>)/ /) {
                $myLigne =~ s/(\((.*\n?)(\)))//;
                push @newFile, &parseLigne($myLigne) ;
            }
            else {
                $myLigne =~ s/(\((.*\n?)(\)))//;
                push @newFile, &parseLigne($myLigne) ;
            }
        }
        else {
            $myLigne =~ s/(\((.*\n?)(\)))//;
            push @newFile, &parseLigne($myLigne) ;
        }
    }

    return @newFile;
}

################################################################################
# Pour chaque texte dans le repertoire
################################################################################
foreach(@Files) {
	#On met l'ensemble du fichier texte dans la variable $file
	my $file ;
	open($file, "<", $_) or die "Can't open $_ : $!" ;

    #Dans le fichier de réponses on met le nom du fichier pour le réponses
    print("Fichier ------> ", $_, "\n");

	#Quand on a l'ensemble du fichier, on le met dans une array et on envoie l'array à la fonction
	@tmpFile = recupererLigneAvecRegex(<$file>) ;
	my @fileFiltre = Mots_Fonctionnels_a(@tmpFile) ;

    #On fait les n-grammes
    $ng->process_text(@fileFiltre);

    #On affiche les données des mot clé des N-grammes dans le fichier de résultat
    print $ng->to_string( orderby => "frequency" ,onlyfirst => 2);
    print "\n\n\n\n\n\n\n"
}

#-------------------------------------------------------------------------------
# Lecture de stopwords
# Fournit par Mr Torres du LIA
#-------------------------------------------------------------------------------
sub Mots_Fonctionnels_a {
    open(FON, "fonctionnels_en.txt") or die ;    # Dico de mots fonctionels
    my %stopwords=();            # Hash de fonctionnels
    while (my $mot=<FON>) {
        chomp($mot) ;            # Eliminer le \n
        next if $mot =~ /^#/ || $mot =~ /^[\s]*\|/ || $mot =~ /^$/ ;
        $mot =~ s/#.+$// ;        # Eliminer commentaires
        $mot =~ s/\s(?<![ \n])//g;
        $mot =~ s/ \K +//g;
        $mot =~ s/\n\n\K\n+//g;
        $mot =~ s/\s+// ;        # Eliminer les espaces genânts
        $stopwords{$mot}++;        # Le mot existe
    } close FON ;

    return Mots_Fonctionnels_b(\%stopwords) ;
}

#-------------------------------------------------------------------------------
# Mots_Fonctionnels() b
# Description : Enlever mots fonctionnels
# Sorties :     %Texte_filtre Le texte nettoye
# Fournit par Mr Torres du LIA
#-------------------------------------------------------------------------------
sub Mots_Fonctionnels_b {
    my ($stopwords) = @_ ;    # Argument = pointeur de stopwords
    my @Texte_filtre;         # Texte nettoye
    foreach my $phrase (@tmpFile) {     # Toutes les phrases
        my @words  = split / +/,$phrase ;    # Chaque phrase
        my $phrase_filtree = join ' ', grep { !$stopwords->{$_} } @words ; # Eliminer les stopwords
        $phrase_filtree = " " if $phrase_filtree=~/^$/;    # Verifier que la phrase ne soit pas vide
        push @Texte_filtre, $phrase_filtree ;
    }
    return @Texte_filtre ;                        # Phrases filtrées
}