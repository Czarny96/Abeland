varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_sampler;
uniform lowp vec4 tint;
uniform lowp vec4 colorize;
uniform lowp vec4 brightness; // only 'r' is used - we can pass only vec4


void main()
{
    // apply tint
    lowp vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    vec4 color = texture2D(texture_sampler, var_texcoord0.xy) * tint_pm;
    
    lowp vec3 retval = vec3(color);

    // apply color
    retval.r *= colorize.r;
    retval.g *= colorize.g;
    retval.b *= colorize.b;

    // apply brightness
    retval.r *= brightness.r;
    retval.g *= brightness.r;
    retval.b *= brightness.r;

    
    gl_FragColor = vec4(retval.rgb, color.a);
}