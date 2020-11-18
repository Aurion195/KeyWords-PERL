#!/usr/bin/perl
use strict;
use warnings;
#On va créer un array contenant tous les fichiers texte
my @text = ("10_JPCO/jpco_1_1_011001.txt") ;
my @tmpFile ;

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
	
	#Nous allons supprimer les lignes que nous ne voulons pas
	if(($myLigne =~ s/(?=< tex-math >)(.*\n?)(< \/tex-math >)/ /) || ($myLigne =~ s/(?=<mml:math>)(.*\n?)(<\/math>)/ /)) {
		    if($myLigne =~ s/(?=<mml:math>)(.*\n?)(<\/math>)/ /) {

			push @newFile, &parseLigne($myLigne) ;    
		    }
		    else {
			push @newFile, &parseLigne($myLigne) ;
		    }
	}
	else {
	    push @newFile, &parseLigne($myLigne) ;
	}
    }

    return @newFile;
}

################################################################################
# Pour chaque texte dans le repertoire
################################################################################
foreach(@text) {
	#On met l'ensemble du fichier texte dans la variable $file
	my $file ;
	open($file, "<", $_) or die "Can't open $_ : $!" ;

	#Quand on a l'ensemble du fichier, on le met dans une array et on envoie l'array à la fonction   
	@tmpFile = recupererLigneAvecRegex(<$file>) ;
	my @fileFiltre = Mots_Fonctionnels_a(@tmpFile) ;
    print @fileFiltre;
}

#-------------------------------------------------------------------------------
# Lecture de stopwords
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