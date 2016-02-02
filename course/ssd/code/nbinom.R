

nbinom_devfun <- function(y, offset)
{
    function(coef, log_shape)
    {
        k <- exp(log_shape)

        eta <- coef + offset
        mu <- exp(eta)

        if (is.finite(k)) {
            log_table <- c(0, log_shape, log(seq(k + 1, length.out=max(y) - 1)))
            const_table <- cumsum(log_table)
            const <- sum(const_table[y + 1])

            eta <- coef + offset
            mu  <- exp(eta)
            log_a_mu <- eta - log_shape
            a_mu <- exp(log_a_mu)

            l <- const + sum(y * (log_a_mu - log1p(a_mu)) - k * log1p(a_mu))
        } else {
            l <- sum(y * eta  - mu)
        }

        (-2) * l
    }
}


nbinom_deviance <- function(y, offset, log_shape)
{
    k <- exp(log_shape)

    function(coef)
    {
        eta <- coef + offset
        mu  <- exp(eta)
        log_a_mu <- eta - log_shape
        a_mu <- exp(log_a_mu)

        l <- sum(y * (log_a_mu - log1p(a_mu)) - k * log1p(a_mu))
        f <- (-2) * l
        g <- -2 * sum((y - mu) / (1 + a_mu))
        h <- 2 * sum((mu + a_mu * y)/(1 + a_mu)^2)

        res <- f
        attr(res, "gradient") <- g
        attr(res, "hessian") <- h
        res
    }
}

nbinom_fit <- function(y, n, method = "mle")
{
    if (method == "mle") {
        nbinom_fit_mle(y, n)
    } else if (method == "moment") {
        nbinom_fit_moment(y, n)
    } else if (method == "breslow") {
        nbinom_fit_breslow(y, n)
    } else {
        stop("unrecognized fitting method: '", method, "'")
    }
}

nbinom_pdev <- function(y, offset, log_shape)
{
    ymax <- max(y)
    if (ymax == 0) {
        res <- 0
        attr(res, "log_rate") <- 0
        return(res)
    }
    pois_log_rate <- log(sum(y) / sum(exp(offset)))

    # const <- -2 * sum(lgamma(y + k) - lgamma(k))
    k <- exp(log_shape)
    log_table <- c(0, log_shape, log(seq(k + 1, length.out=max(y) - 1)))
    const_table <- cumsum(log_table)
    const <- -2 * sum(const_table[y + 1])

    f0 <- nbinom_deviance(y, offset, log_shape)
    opt <- nlm(f0, pois_log_rate, check.analyticals=FALSE)
    stopifnot(opt$code != 4)
    res <- opt$minimum + const
    attr(res, "log_rate") <- opt$estimate
    res
}

nbinom_fit_mle <- function(y, n)
{
    pois_rate <- sum(y) / sum(n)
    if (pois_rate == 0) {
        return(list(deviance = 0, rate = 0,
                    heterogeneity = 0, pois_deviance = 0,
                    pois_rate = 0))
    }

    offset <- log(n)
    pois_log_rate <- log(pois_rate)
    eta <- pois_log_rate + offset
    mu <- exp(eta)
    pois_dev <- (-2) * sum(y * eta - mu)

    f <- function(log_shape)
    {
        # const <- -2 * sum(lgamma(y + k) - lgamma(k))
        k <- exp(log_shape)
        log_table <- c(0, log_shape, log(seq(k + 1, length.out=max(y) - 1)))
        const_table <- cumsum(log_table)
        const <- -2 * sum(const_table[y + 1])

        f0 <- nbinom_deviance(y, offset, log_shape)
        opt <- nlm(f0, pois_log_rate, check.analyticals=FALSE)
        stopifnot(opt$code != 4)
        res <- opt$minimum + const
        attr(res, "log_rate") <- opt$estimate
        res
    }

    opt <- optim(0, f, method="Brent", lower=-100, upper=100)
    stopifnot(opt$convergence == 0)
    log_shape <- opt$par
    log_rate <- attr(opt$value, "log_rate")
    deviance <- as.numeric(opt$value)

    list(deviance = deviance, rate = exp(log_rate),
         heterogeneity = exp(-log_shape),
         pois_deviance = pois_dev, pois_rate = pois_rate)
}


nbinom_fit_moment <- function(y, n)
{
    nobs <- length(y)
    ntot <- sum(n)

    mean <- sum(y) / ntot
    if (mean == 0) {
        return(list(mean = 0, heterogeneity = 0))
    }

    var <- (sum(n * (y / n - mean)^2) / (nobs - 1))
    r <- ((ntot - sum(n^2) / ntot) / (nobs - 1))

    theta <- (var - mean) / (mean * r)
    hetero <- if (theta < 0) 0 else theta / mean
    list(rate = mean, heterogeneity = hetero)
}


nbinom_fit_breslow <- function(y, n)
{
    nobs <- length(y)
    ntot <- sum(n)
    rate <- sum(y) / ntot

    if (rate == 0) {
        return(list(rate=0, heterogeneity=0))
    }

    mu <- n * rate

    f <- function(a) {
        mean((y - mu)^2 / (mu * (1 + a * mu))) - 1 + 1/nobs
    }

    if (f(0) <= 0) {
        hetero <- 0
    } else {
        max <- 10
        while (f(max) >= 0) {
            max <- max * 5
        }
        hetero <- uniroot(f, c(0, max), tol=1e-8)$root
    }

    list(rate = rate, heterogeneity = hetero)
}
