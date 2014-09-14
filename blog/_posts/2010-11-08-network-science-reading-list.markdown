---
layout: post
title: Network Science Reading List
category: Networks
---

Network science is a huge field spanning many disciplines; for newcomers,
it is to know where to start.  What follows is an incomplete list of network
science papers I found to be interesting, organized by topic.


Exponential Random Graph Models
-------------------------------

ERGMs are the most widely-used network models in the social sciences.
They model relational data through statistics like the numbers of triangles
and k-star subgraphs.  Unfortunately, they are difficult to fit and interpret.

 * Holland, P. W., and Leinhardt, S. (1981),
   ["An Exponential Family of Probability Distributions for Directed Graphs,"][holland1981]
   _J. Am. Stat. Assoc._, **76**, 33-50

 * Anderson, C. J., Wasserman S., and Crouch, B. (1999),
   ["A p* Primer: Logit Models for Social Networks,"][anderson1999]
   _Soc. Networks_, **21**, 37-66

 * Snijders, T. A. B. (2002),
   [“Markov Chain Monte Carlo Estimation of Exponential Random Graph Models,”][snijders2002]
   _J. Soc. Struct._, **3**, 1-40

 * Handcock, M. S. (2003),
   [“Assessing Degeneracy in Statistical Models of Social Networks,”][handcock2003]
   Working paper no. 39, Center for Statistics and the Social Sciences,
   University of Washington-Seattle

[anderson1999]:http://linkinghub.elsevier.com/retrieve/pii/S0378873398000124
[handcock2003]:http://www.csss.washington.edu/Papers/wp39.pdf
[holland1981]:http://www.jstor.org/stable/2287037
[snijders2002]:http://www.cmu.edu/joss/content/articles/volume3/Snijders.pdf


Latent Space Models
-------------------

Latent space models are an alternative to ERGMs which get around dyadic
dependence by positing existence of latent covariates.  Since their
introduction in 2002, they have been extended to include clustering and degree
heterogeneity.  Beware that these models impose a triangle inequality on
social space, which may not be appropriate.

 * Hoff, P. D., Raftery, A. E., and Handcock, M. S. (2002),
   [“Latent Space Approaches to Social Network Analysis,”][hoff2002]
   _J. Am. Stat. Assoc._, **97**, 1090–1098

 * Handcock, M. S., Raftery, A. E., and Tantrum, J. M. (2007),
   ["Model-Based Clustering for Social Networks,"][handcock2007]
   _J. R. Statist. Soc. A_, **170**, 301-354

 * Krivitsky, P. N., Handcock, M. S.,  Raftery, A. E., and Hoff, P. D. (2009),
   ["Representing Degree Distributions, Clustering, and Homophily in Social Networks with Latent Cluster Random Effects Models,"][krivitsky2009]
   _Soc. Networks_, **31**, 204-213

[hoff2002]:http://www.stat.washington.edu/raftery/Research/PDF/hoff2002.pdf
[handcock2007]:http://www.stat.washington.edu/raftery/Research/PDF/Handcock2007.pdf
[krivitsky2009]:http://www.stat.washington.edu/raftery/Research/PDF/Krivitsky2009.pdf


Block Models
------------

Block models are another class of network models involving latent variables.
While work in the 80s assumed the block structure to be known, the current
approach is to assume each node belongs to an unknown class, and the node's
behavior is determined by its class membership.  Bickell and Chen have
shown it is possible to recover the unknown class labels if the network is
big enough.

 * Holland, P. W., Laskey, K. B., and Leinhardt, S. (1983),
   [“Stochastic Blockmodels: First Steps,”][holland1983]
   _Soc. Networks_, **5**, 109–137

 * Airoldi, E. M., Blei, D. M., Feinberg, S. E., and Xing, E. P. (2008),
   ["Mixed Membership Stochastic Blockmodels,"][airoldi2008]
   _J. Mach. Learn. Res._, **9**, 1981-2014

 * Bickell, P. and Chen, A. (2009),
   [“A Nonparametric View of Network Models and Newman-Girvan and Other Modularities,”][bickell2009]
   _P. Natl. Acad. Sci._, **106**, 21068–21073

[airoldi2008]:http://jmlr.csail.mit.edu/papers/volume9/airoldi08a/airoldi08a.pdf
[bickell2009]:http://www.stat.berkeley.edu/~bickel/Bickel%20Chen%2021068.full.pdf
[holland1983]:http://dx.doi.org/10.1016/0378-8733(83)90021-7


Agent-Based Models
------------------

Agent-based models are similar in spirit to latent space models (network
dynamics arise from pairwise behavior) while still keeping some of the
attractive features of ERGMs (explicit transitivity or hub/spoke behavior).

 * Jackson, M. O. and Wolinsky, A. (1996),
   ["A Strategic Model of Social and Economic Networks,"][jackson1996]
   _J. Econ. Theory._, **71**, 44-74

 * Snijders, T. A. B., Van de Bunt, G. V., and Steglich, C. E. G. (2010),
   ["Introduction to Stochastic Actor-Based Models for Network Dynamics,"][snijders2010]
   _Soc. Networks_, **32**, 44–60

[jackson1996]:http://dx.doi.org/10.1006/jeth.1996.0108
[snijders2010]:http://stat.gamma.rug.nl/SnijdersSteglichVdBunt2009.pdf


Community Detection
-------------------

Community detection in networks is like clustering in traditional data
analysis.  For some reason, this has received a lot of attention, especially
in the physics community.  This seems like a fad, but it's worth knowing
about.

 * Newman, M. E. J. (2006),
   ["Modularity and Community Structure in Networks,"][newman2006]
   _P. Natl. Acad. Sci._, **103**, 8577-8582

 * Leskovec, J., Lang, K. J., Dasgupta A., and Mahoney, M. W. (2009),
   ["Community Structure in Large Networks: Natural Cluster Sizes and the Absence of Large Well-Defined Clusters,"][leskovec2009]
   _Internet Mathematics_, **6**, 29-123

[leskovec2009]:http://arxiv.org/abs/0810.1355
[newman2006]:http://arxiv.org/abs/physics/0602124


Sampling
--------

Sampling and missing data issues are extremely important, but they largely
get ignored.  Mostly, this is because they give rise to really
hard problems.  Often theoretical results are negative--in particular, many
have attacked respondent-driven sampling--but without constructive
alternatives, it will be hard to advance the field.

 * Heckathorn, D. D. (1997),
   ["Respondent-Driven Sampling: A New Approach to the Study of Hidden Populations,"][heckathorn1997]
    _Social Problems_, **44**, 174-199

 * Achlioptas, D., Clauset, A., Kempe, D., and Moore, C. (2009),
   ["On the Bias of Traceroute Sampling: Or, Power-Law Degree Distributions in Regular Graphs,"][achlioptas2009]
   _J. ACM_, **56**, 1-28

 * Handcock, M. S. and Gile, K. J. (2010),
   ["Modeling Social Networks from Sampled Data,"][handcock2010]
   _Ann. Appl. Stat._, **4**, 5-25

[achlioptas2009]:http://users.soe.ucsc.edu/~optas/papers/traceroute.pdf
[handcock2010]:http://imstat.org/aoas/AOAS221.pdf
[heckathorn1997]:http://www.respondentdrivensampling.org/reports/RDS1.pdf


Applications
------------

The dirty secret of network science is that the hype is disproportionate
to the scientific impact.  Below are two of the more important
application-driven results.  The Christakis and Fowler (2007) paper in
particular generated significant attention, both positive and negative.

 * Morris, M. (1997),
   ["Concurrent Partnerships and the Spread of HIV,"][morris1997]
   _AIDS_, **11**, 641-648

 * Christakis, N. A. and Fowler, J. H. (2007),
   ["The Spread of Obesity in a Large Social Network over 32 Years,"][christakis2007]
   _New Engl. J. Med._, **357**, 370-379

[christakis2007]:http://www.nejm.org/doi/full/10.1056/NEJMsa066082
[morris1997]:http://journals.lww.com/aidsonline/Fulltext/1997/05000/Concurrent_partnerships_and_the_spread_of_HIV.12.aspx
