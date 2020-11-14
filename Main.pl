#!/usr/bin/perl
use strict;
use warnings;

#Permet de parser le fichier et de récuperer uniquement ce dont on à besoin
sub recupererLigneAvecRegex {
    my @args = @_ ;
    my @newFile = {} ;
    #Pour chaque ligne dans le fichier que l'on fait
    foreach my $myLigne (@args) {
        #On va selectionner les lignes que l'on ne met pas dedans le nouveau fichier
        if($myLigne =~ m/(^(TYPE|DOI|JOURNAL|DATE|AUTHOR|ADDRESS|ACRONYMS|KEYWORDS).*)/) {
            next ;
        }
        
        #Nous allons supprimer les 
        if(($myLigne =~ s/(?=< tex-math >)(.*\n?)(< \/tex-math >)/ /) || ($myLigne =~ s/(?=<mml:math>)(.*\n?)(<\/math>)/ /)) {
            if($myLigne =~ s/(?=<mml:math>)(.*\n?)(<\/math>)/ /) {
                push @newFile, lc($myLigne) ;    
            }
            else {
                push @newFile, lc($myLigne) ;
            }
        }
        else {
            push @newFile, lc($myLigne) ;
        }
    }

    return @newFile;
}

#On va créer un array contenant tous les fichiers texte
my @text = ("10_JPCO/jpco_1_1_011001.txt") ;


#Pour chaque texte dans le repertoire
foreach(@text) {
    #On met l'ensemble du fichier texte dans la variable $file
    my $file ;
    open($file, "<", $_) or die "Can't open $_ : $!" ;

    #Quand on a l'ensemble du fichier, on le met dans une array et on envoie l'array à la fonction   
    my @newFile = &recupererLigneAvecRegex(<$file>) ;
    
    

    print"@newFile";
    #foreach my $myLigne (@ligne) {
    #    chomp $myLigne;
    #
    #    foreach my $str (split /\s+/, $myLigne) {
    #        $count{$str}++;
    #    }
    #}
    
    #foreach my $word (reverse sort { $count{$a} <=> $count{$b} } keys %count) {
    #    #printf "%-31s %s\n", $word, $count{$word};
    #}
}